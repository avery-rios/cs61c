use crate::image::{Color, Image};

#[derive(Debug, Clone, Copy)]
pub struct Rule(pub u32);

fn color_to_int(c: Color) -> u32 {
    u32::from_be_bytes([0, c.r, c.g, c.b])
}
fn int_to_color(i: u32) -> Color {
    let [_, r, g, b] = i.to_be_bytes();
    Color { r, g, b }
}

fn eval_pixel(
    rule: Rule,
    top_row: &[Color],
    row: &[Color],
    bottom_row: &[Color],
    c: usize,
) -> Color {
    let column = row.len();
    let left_col = if c == 0 { column - 1 } else { c - 1 };
    let right_col = if c == column - 1 { 0 } else { c + 1 };

    let neighbor = [
        top_row[left_col],
        top_row[c],
        top_row[right_col],
        row[left_col],
        row[right_col],
        bottom_row[left_col],
        bottom_row[c],
        bottom_row[right_col],
    ]
    .map(color_to_int);

    let mut val = 0u32;
    let px = color_to_int(row[c]);
    for i in 0..24 {
        let live_cnt: u32 = neighbor.iter().map(|v| (v >> i) & 1).sum();
        let offset = live_cnt + if (px >> i) & 1 == 1 { 9 } else { 0 };
        val |= ((rule.0 >> offset) & 1) << i;
    }
    int_to_color(val)
}

pub fn game_of_life(i: &Image, rule: Rule) -> Image {
    let mut image = Vec::with_capacity(i.rows as usize);
    for (r, row) in i.image.iter().enumerate() {
        let top_row = &i.image[if r == 0 { i.rows as usize - 1 } else { r - 1 }];
        let bottom_row = &i.image[if r == i.rows as usize - 1 { 0 } else { r + 1 }];

        let mut vr = Vec::with_capacity(i.cols as usize);
        for c in 0..i.cols {
            vr.push(eval_pixel(rule, top_row, row, bottom_row, c as usize))
        }
        image.push(vr);
    }

    Image {
        rows: i.rows,
        cols: i.cols,
        image,
    }
}
