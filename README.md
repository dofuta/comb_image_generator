# comb_image_generator

## Setup

1. Install bundler with gem.
```
gem install bundler
```

2. Run bndler to install gems.
```
bundle install
```

3. Set image files into assets/ directory as the following structure.
```
assets
   -- dir1
     -- image1.png
     -- image2.png
     -- image3.png
   -- dir2
     -- image1.png
     -- image2.png
     -- image3.png
   -- dir3
     -- image1.png
     -- image2.png
     -- image3.png
   -- dir4
     -- image1.png
     -- image2.png
     -- image3.png
```

4. Set the config file as the followings.
> Set the base item directory name and the decoration item derectory name on config.yml
```
max_result_num: 10000   # Limit max number of image generation.
assets_path: "./assets" # Assets folder path
files:
  items_base:           # Put the base items directorie names.
    - "1_background"
    - "2_body"
    - "3_wear"
  items_deco:           # Put the decoration items directorie names.
    - "5_eyes"
    - "6_eye-wear"
    - "7_hat"
    - "8_mouth"
    - "9_shose"
```

## Run the program
1. Just run:
```
bundle exec ruby generate.rb
```
Then, you can see the result generated images at result/ directory.
