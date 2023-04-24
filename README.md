# Visus

## Description

Flutter screens made easy.

The compiler is made to create screens with less friction.

## Usage

```sh
fvm dart run bin\visus.dart samples\screen.vs
```

With this command, you can read and evaluate the UI program compiling a screen in flutter.

The following content is present on the `samples\screen.vs` file:

```
scaffold {
  appbar {
    title: "Visus"
  }
  body {
    column [
      button {
        text: "Click me to visualize!"
      }
    ]
  }
}
```