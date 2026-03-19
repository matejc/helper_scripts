local cutils = require ("common-utils")
local lutils = require ("linking-utils")

local config = ...
local rules = config:parse()["rules"]

for i, v in ipairs(rules) do
    print("Rule #" .. i)
    print("  Match stream by:")
	for k, v in pairs(v.stream) do
		print("    " .. k .. " = " .. v)
	end
    print("  Match node by:")
	for k, v in pairs(v.node) do
		print("    " .. k .. " = " .. v)
	end
end

local allNodes = {};
local allStreams = {};

local function properties_matches_rule(properties, criteria)
    if not properties then
        return false
    end

    for key, expected_value in pairs(criteria) do
        local actual_value = properties[key]
        if not actual_value then
            return false
        end

        if string.sub(expected_value, 1, 1) == "/" and string.sub(string.reverse(expected_value), 1, 1) == "/" then
            local expected_value_pattern = string.sub(expected_value, 2, string.len(expected_value)-1)
            if not string.match(actual_value, expected_value_pattern) then
                return false
            end
        else
            if actual_value ~= expected_value then
                return false
            end
        end
    end
    return true
end

local function find_node_by_stream(stream)
    -- Iterate rules first to preserve priority order
    for _, rule in ipairs(rules) do
        if properties_matches_rule(stream.properties, rule.stream) then
            -- Now find the node that matches this rule's node criteria
            for _, node in pairs(allNodes) do
                if properties_matches_rule(node.properties, rule.node) then
                    return node
                end
            end
        end
    end
    return nil
end

local function find_streams_for_node(node)
    local matched = {}
    -- Iterate rules first to preserve priority order
    for _, rule in ipairs(rules) do
        if properties_matches_rule(node.properties, rule.node) then
            for _, stream in pairs(allStreams) do
                if properties_matches_rule(stream.properties, rule.stream) then
                    -- Only match if this node is the best match for the stream
                    local best_node = find_node_by_stream(stream)
                    if best_node and best_node.properties["node.name"] == node.properties["node.name"] then
                        table.insert(matched, stream)
                    end
                end
            end
        end
    end
    return matched
end

local function find_si_for_node(si_om, node)
    for si in si_om:iterate() do
        local si_node = si:get_associated_proxy("node")
        if si_node and si_node["bound-id"] == node["bound-id"] then
            return si
        end
    end
    return nil
end

local function make_link(si_node, si_stream)
    local link = SessionItem("si-standard-link")

    local si_props = si_stream.properties
    local target_props = si_node.properties
    local passthrough = false
    local exclusive = cutils.parseBool(si_props["node.exclusive"])
    local is_role_policy_link = lutils.is_role_policy_target(si_props, target_props)

    -- si_stream has item.node.direction = "output" -> it is the out.item
    -- si_node has item.node.direction = "input" -> it is the in.item
    -- port contexts are the reverse of the node direction for si-standard-link
    local out_context = si_props["item.node.direction"]   -- "output"
    local in_context = target_props["item.node.direction"] -- "input"

    local configured = link:configure {
      ["out.item"] = si_stream,
      ["in.item"] = si_node,
      ["out.item.port.context"] = out_context,
      ["in.item.port.context"] = in_context,
      ["passthrough"] = passthrough,
      ["exclusive"] = exclusive,
      ["media.role"] = si_props["media.role"],
      ["target.media.class"] = target_props["media.class"],
      ["policy.role-based.priority"] = target_props["policy.role-based.priority"],
      ["policy.role-based.action.same-priority"] = target_props["policy.role-based.action.same-priority"],
      ["policy.role-based.action.lower-priority"] = target_props["policy.role-based.action.lower-priority"],
      ["is.role.policy.link"] = is_role_policy_link,
      ["main.item.id"] = si_stream.id,
      ["target.item.id"] = si_node.id,
    }

    if not configured then
        print("FAILURE: link:configure returned false")
        return
    end

    link:register()

    link:activate(Feature.SessionItem.ACTIVE, function(item, e)
        if e then
            print("Link activation error:", e)
        else
            print("Link activated successfully:", item)
        end
    end)
end

local function connect_stream(stream, node, source)
    print(node.properties["node.name"], " -> ", stream.properties["node.name"])

    local si_om = source:call("get-object-manager", "session-item")
    local si_node = find_si_for_node(si_om, node)
    local si_stream = find_si_for_node(si_om, stream)

    if not si_node then
        print("FAILURE: could not find session item for node:", node.properties["node.name"])
        return
    end
    if not si_stream then
        print("FAILURE: could not find session item for stream:", stream.properties["node.name"])
        return
    end

    make_link(si_node, si_stream)
end

local function find_node_name_by_bound_id(bound_id)
    for name, node in pairs(allNodes) do
        if node["bound-id"] == bound_id then
            return name
        end
    end
    return nil
end

local function find_stream_name_by_bound_id(bound_id)
    for name, stream in pairs(allStreams) do
        if stream["bound-id"] == bound_id then
            return name
        end
    end
    return nil
end


SimpleEventHook {
    name = "autoconnect-node-added",
    interests = {
        EventInterest {
            Constraint { "event.type", "=", "node-added" },
            Constraint { "media.class", "matches", "Audio/*" },
        },
    },
    execute = function(event)
        local node = event:get_subject()
        local source = event:get_source()
        if node and node.properties and node.properties["node.name"] then
            print("Node added:", node.properties["node.name"])
            allNodes[node.properties["node.name"]] = node

            -- Check if any existing streams should connect to this node
            local streams = find_streams_for_node(node)
            for _, stream in ipairs(streams) do
                print("Connecting existing stream to new node:", stream.properties["node.name"])
                connect_stream(stream, node, source)
            end
        end
    end
}:register ()

SimpleEventHook {
    name = "autoconnect-node-removed",
    interests = {
        EventInterest {
            Constraint { "event.type", "=", "node-removed" },
            Constraint { "media.class", "matches", "Audio/*" },
        },
    },
    execute = function(event)
        local node = event:get_subject()
        local source = event:get_source()
        if node then
            -- properties may already be nil at removal time, look up by bound-id
            local node_name = find_node_name_by_bound_id(node["bound-id"])
            if node_name then
                print("Node removed:", node_name)
                allNodes[node_name] = nil

                -- Reconnect any streams that were connected to this node
                -- to the next best node according to rules
                for _, stream in pairs(allStreams) do
                    local next_node = find_node_by_stream(stream)
                    if next_node then
                        print("Reconnecting stream to next best node:", stream.properties["node.name"], "->", next_node.properties["node.name"])
                        connect_stream(stream, next_node, source)
                    end
                end
            else
                print("Node removed: (unknown)")
            end
        end
    end
}:register ()

SimpleEventHook {
    name = "autoconnect-stream-added",
    interests = {
        EventInterest {
            Constraint { "event.type", "=", "node-added" },
            Constraint { "media.class", "matches", "Stream/*/Audio", type = "pw-global" },
            Constraint { "stream.monitor", "!", "true", type = "pw" },
        },
    },
    execute = function(event)
        local stream = event:get_subject()
        local source = event:get_source()
        if stream.properties then
            print("Stream added:", stream.properties["application.name"])
            allStreams[stream.properties["node.name"]] = stream

            local node = find_node_by_stream(stream)
            if node then
                connect_stream(stream, node, source)
            end
        end
    end
}:register ()

SimpleEventHook {
    name = "autoconnect-stream-removed",
    interests = {
        EventInterest {
            Constraint { "event.type", "=", "node-removed" },
            Constraint { "media.class", "matches", "Stream/*/Audio", type = "pw-global" },
            Constraint { "stream.monitor", "!", "true", type = "pw" },
        },
    },
    execute = function(event)
        local stream = event:get_subject()
        if stream then
            -- properties may already be nil at removal time, look up by bound-id
            local stream_name = find_stream_name_by_bound_id(stream["bound-id"])
            if stream_name then
                print("Stream removed:", stream_name)
                allStreams[stream_name] = nil
            else
                print("Stream removed: (unknown)")
            end
        end
    end
}:register ()
