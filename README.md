# Kindlize Email

Read newsletters on your Kindle!

## Usage

_Note: this is currently only set up to work on mac, but modifying it to work elsewhere should be pretty easy._

1. download and install [calibre](https://calibre-ebook.com/download_osx) (this uses the `ebook-convert` executable to convert an html file to a mobi file)
1. run `bin/setup`
1. run `bin/eml-to-mobi <path to .eml file>`
1. email `out.mobi` to your Kindle

## Apple Script Quick Action

Add this to Automator:

```bash
for f in "$@"
do
    cd <path to this repo> && \
    bin/eml-to-mobi "$f" && \
    mv out.mobi "${f}.mobi"
done
```

![Example of clicking the quick action](example1.png)
![Example of the result of the quick action](example2.png)

_Note: if you get errors with ruby versions, try adding `bundle exec` before the `bin/eml-to-mobi` call_
