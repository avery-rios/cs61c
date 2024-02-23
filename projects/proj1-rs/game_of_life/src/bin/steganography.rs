use std::{env, fs, io};

use game_of_life::{image::Image, steganography::steganography};

fn main() {
    let filename = {
        let mut a = env::args();
        a.next();
        a.next().unwrap()
    };
    let img = Image::read(&fs::read_to_string(filename).unwrap()).unwrap();
    steganography(&img).write(io::stdout()).unwrap()
}
