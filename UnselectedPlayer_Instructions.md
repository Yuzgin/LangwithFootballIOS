# UnselectedPlayer Image Instructions

## Where to upload the unselected player image:

1. **Open Xcode** and navigate to your project
2. **Go to the Assets.xcassets folder** in your project navigator
3. **Right-click** on the Assets.xcassets folder
4. **Select "New Image Set"**
5. **Name it "UnselectedPlayer"** (exactly as shown, case-sensitive)
6. **Drag and drop your unselected player image** into the 1x, 2x, and 3x slots

## Image Requirements:

- **Size**: 55x55 points (so 55x55, 110x110, 165x165 pixels for 1x, 2x, 3x)
- **Format**: PNG with transparency
- **Style**: Should match the existing PlayerIcon and PlayerIconGK style
- **Content**: A generic player silhouette or icon that represents an empty player slot

## Alternative Image Names:

If you prefer a different name, you can change the image name in the code:
- Open `TeamPlayerIconView.swift`
- Find the line: `Image("UnselectedPlayer")`
- Change "UnselectedPlayer" to your preferred name
- Make sure the image set name in Assets.xcassets matches exactly

## Suggested Image Ideas:

- A simple player silhouette with a dashed outline
- A player icon with a "?" or "+" symbol
- A transparent/outlined version of the existing PlayerIcon
- A generic football player icon with reduced opacity

The image will be displayed in a circular frame, so make sure it looks good when cropped to a circle.
