# TextPaths

**TextPaths** is an utility for converting `NSAttributedText` to vector representation where each character of an input text is represented as a `CGPAth` glyph. **TextPaths** also returns typographic propeties for lines and entire text flow. For in-depth knowledge on how iOS handles text see [Using Text Kit to Draw and Manage Text](https://developer.apple.com/library/archive/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/CustomTextProcessing/CustomTextProcessing.html) chapter in documentation.

Source `NSAttributedText` is converted into a tree like representation with char glyphs on leafs.

```
 TextPath
    ⎿ TextPathFrame[]
        ⎿ TextPathLine[]
            ⎿ TextPathGlyph[]

    ⎿ ComposedTextPath
```

`TextPathFrame` - text frame representation

<img src="https://raw.githubusercontent.com/malczak/TextPaths/master/_Assets/textpaths-bounds-01.jpg" height="120" width="auto"/>

`TextPathLine` - single text line representation

<img src="https://raw.githubusercontent.com/malczak/TextPaths/master/_Assets/textpaths-bounds-02.jpg" height="120" width="auto"/>

There is also a text bounds rectangle available. Text bounds rectangle is equal or less then line bounds rectangle. On image below this metric is show in purple.

<img src="https://raw.githubusercontent.com/malczak/TextPaths/master/_Assets/textpaths-bounds-03.jpg" height="120" width="auto"/>

`TextPathGlyph` - single character representation (glyph)

<img src="https://raw.githubusercontent.com/malczak/TextPaths/master/_Assets/textpaths-bounds-04.jpg" height="120" width="auto"/>

`ComposedTextPath` - composed path of entire input text. This is illustrated on all images above in black.

All illustrations were created with [`TextDecompose`](https://github.com/malczak/TextPaths/tree/master/Samples/TextDecompose) sample application.

## Important notes

- `UITextView` has extra edge insets (padding) of apporx 8px
- `UIKit` treats text different than `CoreText` when different font size is used to trailing line-break `\n` character. TextPaths instead of following `CoreText` is using the same approach as `UIKit`. See code comments in `TextPathLine` class for `effectiveDescent` property.

## Production use

This repo is used in my apps

- [Fabristic](https://fabristic.com)
- [Last Day? Life progress and stats](https://apps.apple.com/us/app/last-day-track-events-life/id1193076940?ign-mpt=uo%3D4)

## Sample Applications

### [`TextDecompose`](https://github.com/malczak/TextPaths/tree/master/Samples/TextDecompose)

A sample showing how NSAttributedString is decomposed into CGPaths keeping all attributes and typographic properties.
See screenshots below

### [`TextToSVG`](https://github.com/malczak/TextPaths/tree/master/Samples/TextToSVG)

NSAttributedString to SVG conversion. Entire NSAttributedString is converted in to one merged CGPath and then serialized as SVG path. Resulting SVG is presented in WKWebView for comparison.

### [`FallingLabel`](https://github.com/malczak/TextPaths/tree/master/Samples/FallingLabel)

Falling letters counter application shows how to to use TextPaths for text animations. In this example TextPaths is used to animated UILabel value change.

### [`FlyingText`](https://github.com/malczak/TextPaths/tree/master/Samples/FlyingText)

Another animation example showing how to animate multiline NSAttributedText.

## Screenshots

![asas](https://raw.githubusercontent.com/malczak/TextPaths/master/_Assets/textpaths-nsattributedtext-decompose.jpg | height=480)

<div class="image-wrapper" >
<img src="https://raw.githubusercontent.com/malczak/TextPaths/master/_Assets/textpaths-nsattributedtext-decompose.jpg" height="480" width="auto"/>
 <p class="image-caption"><a href="https://github.com/malczak/TextPaths/tree/master/Samples/TextDecompose" target="_blank">TextDecompose</a></p>
</div>

<div class="image-wrapper" >
<img src="https://raw.githubusercontent.com/malczak/TextPaths/master/_Assets/textpaths-nsattributedtext-to-svg-01.jpg" height="480" width="auto"/>
 <p class="image-caption"><a href="https://github.com/malczak/TextPaths/tree/master/Samples/TextToSVG" target="_blank">TextToSVG  #1</a></p>
</div>

<div class="image-wrapper" >
<img src="https://raw.githubusercontent.com/malczak/TextPaths/master/_Assets/textpaths-nsattributedtext-to-svg-02.jpg" height="480" width="auto"/>
 <p class="image-caption"><a href="https://github.com/malczak/TextPaths/tree/master/Samples/TextToSVG" target="_blank">TextToSVG #2</a></p>
</div>

<div class="image-wrapper" >
<img src="https://raw.githubusercontent.com/malczak/TextPaths/master/_Assets/textpaths-falling-uilabel-animation.gif" height="480" width="auto"/>
 <p class="image-caption"><a href="https://github.com/malczak/TextPaths/tree/master/Samples/FallingLabel" target="_blank">FallingLabel</a></p>
</div>

<div class="image-wrapper" >
<img src="https://raw.githubusercontent.com/malczak/TextPaths/master/_Assets/textpaths-fly-in-text-animation.gif" height="480" width="auto"/>
 <p class="image-caption"><a href="https://github.com/malczak/TextPaths/tree/master/Samples/FlyingText" target="_blank">FlyingText</a></p>
</div>
