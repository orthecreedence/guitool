# guitool

A tool to help convert executables between GUI and console mode. This is mainly
useful in windows where writing to STDOUT when a console isn't available causes
a "Bad file descriptor" error (hint, use `:win-cui` mode) or when you built an
executable and you want to get rid of the console that pops up (hint, use
`:win-gui` mode).

## Usage

```lisp
(guitool:patch "c:/dev/node-webkit/nw.exe" :win-cui)
(guitool:patch "c:/dev/node-webkit/nw.exe" :win-gui)
...
```

## License

I don't know, actually. I got the code after asking around on reddit, which
turned up <https://gist.github.com/death/6740474>.

When in doubt, ask death.
