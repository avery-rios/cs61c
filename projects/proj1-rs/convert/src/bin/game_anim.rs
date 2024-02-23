use image::imageops;
use std::{env, fs, io, iter, str::FromStr};

use game_of_life::{
    game::{game_of_life, Rule},
    image::Image,
};

fn main() {
    let (filename, rule, count, dest) = {
        let mut a = env::args();
        a.next();
        let f = a.next().unwrap();
        let rule = Rule(u32::from_str_radix(&a.next().unwrap(), 16).unwrap());
        let cnt = usize::from_str(&a.next().unwrap()).unwrap();
        (f, rule, cnt, a.next().unwrap())
    };
    let img = Image::read(&fs::read_to_string(filename).unwrap()).unwrap();
    let width = img.cols * 4;
    let height = img.rows * 4;

    convert::write_gif(
        io::BufWriter::new(
            fs::File::options()
                .write(true)
                .create(true)
                .open(dest)
                .unwrap(),
        ),
        iter::successors(Some(img), |i| Some(game_of_life(i, rule)))
            .map(|i| {
                imageops::resize(
                    &convert::game::to_rgba_image(&i),
                    width,
                    height,
                    imageops::FilterType::Nearest,
                )
            })
            .take(count),
    )
    .unwrap()
}
