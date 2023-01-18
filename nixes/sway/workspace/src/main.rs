use std::{process::Command, cmp::Ordering};

use serde_json::{Value, from_str};

fn get_workspaces() -> Vec<Value> {
    let child = Command::new("swaymsg")
        .arg("-t").arg("get_workspaces")
        .output()
        .expect("get_workspaces failed");

    if let Some(0) = child.status.code() {
        return from_str(&String::from_utf8_lossy(&child.stdout)).unwrap();
    } else {
        panic!("get_workspaces({:?}): {}", child.status.code(), String::from_utf8_lossy(&child.stderr));
    }
}

fn find_by(workspaces: &Vec<Value>, current: i64, step: i64) -> i64 {
    let existing: Vec<i64> = workspaces.into_iter().map(|w| w["num"].as_i64().unwrap()).collect();

    let mut next: i64 = current + step;
    let first: i64 = 1;
    let last: i64 = existing.into_iter().max().unwrap();

    if current == last && step > 0 {
        next = last + step;
    } else if next < first {
        next = first;
    } else if next > last {
        next = last;
    }

    return next;
}

fn find_on_output(workspaces: &Vec<Value>, current: i64, step: i64, output: String) -> i64 {
    let other_wss: Vec<&Value> = workspaces.into_iter().filter(|w| w["output"].to_string() != output).collect();
    let other_nums: Vec<i64> = other_wss.into_iter().map(|w| w["num"].as_i64().unwrap()).collect();

    let other_nums_prev: Vec<i64> = [
        Vec::from([0]),
        other_nums.to_owned().into_iter().filter(|n| n < &current).collect()
    ].concat();
    let other_nums_next: Vec<i64> = other_nums.into_iter().filter(|n| n > &current).collect();

    let mut next: i64 = current + step;

    let first: i64 = other_nums_prev.into_iter().max().unwrap() + 1;

    let last: i64 = if other_nums_next.len() == 0 {
        next
    } else {
        other_nums_next.into_iter().min().unwrap() - 1
    };

    if next < first {
        next = first;
    } else if next > last {
        next = last;
    }

    return next;
}

fn find_output(workspaces: &Vec<Value>, current: i64, step: i64, output: String) -> i64 {
    let other_wss: Vec<&Value> = workspaces.into_iter().filter(|w| w["output"].to_string() != output && w["visible"] == true).collect();

    let other_prevs: Vec<&Value> = other_wss.to_owned().into_iter().filter(|w| w["num"].as_i64().unwrap() < current).collect();
    let other_nexts: Vec<&Value> = other_wss.into_iter().filter(|w| w["num"].as_i64().unwrap() > current).collect();

    match step.cmp(&0) {
        Ordering::Less => {
            return if other_prevs.len() == 0 { current } else { other_prevs.last().unwrap()["num"].as_i64().unwrap() }
        },
        Ordering::Greater => {
            return if other_nexts.len() == 0 { current } else { other_nexts.first().unwrap()["num"].as_i64().unwrap() }
        },
        Ordering::Equal => return current,
    }
}

fn main() {
    let option: String = std::env::args().nth(1).expect("no option given (prev|next|prev_output|next_output|prev_on_output|next_on_output)");

    let workspaces: &Vec<Value> = &get_workspaces();

    let current_ws: &Value = workspaces.into_iter().filter(|w| w["focused"] == true).nth(0).unwrap();
    let current_ws_num: i64 = current_ws["num"].as_i64().unwrap();
    let current_output: String = current_ws["output"].to_string();

    let o: i64 = match option.as_str() {
        "next_on_output" => find_on_output(&workspaces, current_ws_num, 1, current_output),
        "prev_on_output" => find_on_output(&workspaces, current_ws_num, -1, current_output),
        "next_output" => find_output(&workspaces, current_ws_num, 1, current_output),
        "prev_output" => find_output(&workspaces, current_ws_num, -1, current_output),
        "next" => find_by(&workspaces, current_ws_num, 1),
        "prev" => find_by(&workspaces, current_ws_num, -1),
        _ => panic!("Invalid option: {}", option),
    };
    print!("{}", o);
}
