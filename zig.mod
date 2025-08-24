id: ocmr9rtohgccd6gm6tp8b1yzylyzkqwvo1q4btrsvj0cse9y
name: json
main: json.zig
license: MIT
description: "A JSON library for inspecting arbitrary values"
dependencies:
  - src: git https://github.com/nektro/zig-extras
  - src: git https://github.com/nektro/zig-tracer
  - src: git https://github.com/nektro/zig-intrusive-parser
  - src: git https://github.com/nektro/zig-nio

root_dependencies:
  - src: git https://github.com/nektro/zig-nio
  - src: git https://github.com/nektro/zig-nfs
  - src: git https://github.com/nst/JSONTestSuite commit-984defc2deaa653cb73cd29f4144a720ec9efe7c
    id: bebdygynna6kk8zbbprkva6yd28x9wmf57vtzxjn
    license: MIT
    keep: true
