use std::{env, fs, io};

use game_of_life::{
    game::{game_of_life, Rule},
    image::Image,
};

fn main() {
    let (filename, rule) = {
        let mut a = env::args();
        a.next();
        let f = a.next().unwrap();
        let r = Rule(u32::from_str_radix(&a.next().unwrap(), 16).unwrap());
        (f, r)
    };
    let i = Image::read(&fs::read_to_string(filename).unwrap()).unwrap();
    game_of_life(&i, rule).write(io::stdout()).unwrap()
}
