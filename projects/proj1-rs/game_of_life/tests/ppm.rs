use game_of_life::image::Image;

fn test_img(input: &str) {
    let img = Image::read(input).unwrap();
    let mut r = Vec::with_capacity(input.len());
    img.write(&mut r).unwrap();
    assert_eq!(input, std::str::from_utf8(&r).unwrap());
}

#[test]
fn blinker_h() {
    test_img(include_str!("./testInputs/blinkerH.ppm"))
}

#[test]
fn blinker_v() {
    test_img(include_str!("./testInputs/blinkerV.ppm"))
}

#[test]
fn glider_guns() {
    test_img(include_str!("./testInputs/GliderGuns.ppm"))
}

#[test]
fn john_conway() {
    test_img(include_str!("./testInputs/JohnConway.ppm"))
}
