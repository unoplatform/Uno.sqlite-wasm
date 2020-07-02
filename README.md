# SQLite compiled to WebAssembly for the Uno Wasm Bootstrapper

This repository is about building the SQLite library to WebAssembly, and use it as
a Nuget package in an application using [Uno.Wasm.Bootstrap](https://github.com/nventive/Uno.Wasm.Bootstrap).

This repository is based on the work from [Ryusei YAMAGUCHI](https://github.com/mandel59/sqlite-wasm).

## How to use SQLite on WebAssembly

The [`uno.sqlite-wasm`](https://www.nuget.org/packages/Uno.sqlite-wasm) nuget package is available, which is used through [`Uno.SQLitePCLRaw.Wasm`](https://github.com/unoplatform/Uno.SQLitePCLRaw.Wasm).

A sample application can be browsed here: https://github.com/unoplatform/Uno.Samples/tree/master/UI/SQLiteSample, and a guide to use it is [available here](https://github.com/unoplatform/Uno.SQLitePCLRaw.Wasm#usage).