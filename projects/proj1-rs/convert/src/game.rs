use image::{Rgba, RgbaImage};

use game_of_life::image::Image;

pub fn to_rgba_image(image: &Image) -> RgbaImage {
    RgbaImage::from_fn(image.cols, image.rows, |c, r| {
        let c = image.image[r as usize][c as usize];
        Rgba([c.r, c.g, c.b, 0])
    })
}
