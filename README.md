# `cargo_expand.nvim`

Display a selector of compilation targets from your root directory. Run `cargo-expand`
on the selected option. Dump the results into a scratch buffer and flick on syntax
highlights for said buffer.

To be clear, this plugin can be replicated by typing this into your terminal

```bash
cargo expand --lib yourlib > .expanded.rs
nvim .expanded.rs
```

The plugin just has the added _benefit(?)_ of showing a `vim.ui.select` of the parsed
`cargo metadata`.

## Setup

- Lazy

```lua
{
    "chrisp60/cargo_expand.nvim",
    config = function()
        vim.keymap.set("n", "[your keybind]", require("cargo_expand").expand)
    end,
}
```

## TODO

- [ ] Configuration options.
- [ ] Any and all documentation, vim help docs.
- [ ] Display compilation progress in scratch buffer.
- [ ] support for `rustc --emit={llvm-ir, asm, mir, etc..}`.
  - I personally have been trying to write more `unsafe` code, it is nice to see
    how things get represented in assembly and intermediate representations.

## Requirements / Credits

- [`cargo-expand`](https://github.com/dtolnay/cargo-expand)
- [`rustc`](https://github.com/rust-lang/rust) (if you are writing Rust, you have this).
- [`cargo`](https://github.com/rust-lang/cargo/tree/master) (if you are writing Rust, you have this).

## License

- MIT
- Apache

At your choosing.
