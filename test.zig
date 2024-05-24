const std = @import("std");
const json = @import("json");

fn parse_full(buffer: []const u8) !void {
    const alloc = std.testing.allocator;
    var fbs = std.io.fixedBufferStream(buffer);
    var doc = try json.parse(alloc, "", fbs.reader());
    defer doc.deinit(alloc);
}

test {
    try parse_full(
        \\[
        \\  {
        \\    "id": 131325113,
        \\    "author": {
        \\      "login": "github-actions[bot]",
        \\      "id": 41898282,
        \\      "node_id": "MDM6Qm90NDE4OTgyODI=",
        \\      "gravatar_id": "",
        \\      "type": "Bot",
        \\      "site_admin": false
        \\    },
        \\    "node_id": "RE_kwDOEpDmIc4H09y5",
        \\    "tag_name": "r89",
        \\    "target_commitish": "0df96b60dee2a9e76bf12ad8b8ab1d47dba52994",
        \\    "name": "r89",
        \\    "draft": false,
        \\    "prerelease": false,
        \\    "created_at": "2023-11-24T08:33:57Z",
        \\    "published_at": "2023-11-24T08:38:51Z",
        \\    "assets": [
        \\      {
        \\        "id": 137211731,
        \\        "node_id": "RA_kwDOEpDmIc4ILa9T",
        \\        "name": "zigmod-aarch64-linux",
        \\        "label": "",
        \\        "uploader": {
        \\          "login": "github-actions[bot]",
        \\          "id": 41898282,
        \\          "node_id": "MDM6Qm90NDE4OTgyODI=",
        \\          "gravatar_id": "",
        \\          "type": "Bot",
        \\          "site_admin": false
        \\        },
        \\        "content_type": "application/octet-stream",
        \\        "state": "uploaded",
        \\        "size": 12449224,
        \\        "download_count": 28,
        \\        "created_at": "2023-11-24T08:38:52Z",
        \\        "updated_at": "2023-11-24T08:38:53Z",
        \\      },
        \\      {
        \\        "id": 137211736,
        \\        "node_id": "RA_kwDOEpDmIc4ILa9Y",
        \\        "name": "zigmod-aarch64-macos",
        \\        "label": "",
        \\        "uploader": {
        \\          "login": "github-actions[bot]",
        \\          "id": 41898282,
        \\          "node_id": "MDM6Qm90NDE4OTgyODI=",
        \\          "gravatar_id": "",
        \\          "type": "Bot",
        \\          "site_admin": false
        \\        },
        \\        "content_type": "application/octet-stream",
        \\        "state": "uploaded",
        \\        "size": 9137624,
        \\        "download_count": 581,
        \\        "created_at": "2023-11-24T08:38:55Z",
        \\        "updated_at": "2023-11-24T08:38:56Z",
        \\      },
        \\      {
        \\        "id": 137211747,
        \\        "node_id": "RA_kwDOEpDmIc4ILa9j",
        \\        "name": "zigmod-aarch64-windows.exe",
        \\        "label": "",
        \\        "uploader": {
        \\          "login": "github-actions[bot]",
        \\          "id": 41898282,
        \\          "node_id": "MDM6Qm90NDE4OTgyODI=",
        \\          "gravatar_id": "",
        \\          "type": "Bot",
        \\          "site_admin": false
        \\        },
        \\        "content_type": "application/octet-stream",
        \\        "state": "uploaded",
        \\        "size": 7738880,
        \\        "download_count": 23,
        \\        "created_at": "2023-11-24T08:39:00Z",
        \\        "updated_at": "2023-11-24T08:39:01Z",
        \\      },
        \\      {
        \\        "id": 137211740,
        \\        "node_id": "RA_kwDOEpDmIc4ILa9c",
        \\        "name": "zigmod-aarch64-windows.pdb",
        \\        "label": "",
        \\        "uploader": {
        \\          "login": "github-actions[bot]",
        \\          "id": 41898282,
        \\          "node_id": "MDM6Qm90NDE4OTgyODI=",
        \\          "gravatar_id": "",
        \\          "type": "Bot",
        \\          "site_admin": false
        \\        },
        \\        "content_type": "application/octet-stream",
        \\        "state": "uploaded",
        \\        "size": 3813376,
        \\        "download_count": 2,
        \\        "created_at": "2023-11-24T08:38:56Z",
        \\        "updated_at": "2023-11-24T08:38:57Z",
        \\      },
        \\      {
        \\        "id": 137211748,
        \\        "node_id": "RA_kwDOEpDmIc4ILa9k",
        \\        "name": "zigmod-mips64-linux",
        \\        "label": "",
        \\        "uploader": {
        \\          "login": "github-actions[bot]",
        \\          "id": 41898282,
        \\          "node_id": "MDM6Qm90NDE4OTgyODI=",
        \\          "gravatar_id": "",
        \\          "type": "Bot",
        \\          "site_admin": false
        \\        },
        \\        "content_type": "application/octet-stream",
        \\        "state": "uploaded",
        \\        "size": 12545712,
        \\        "download_count": 3,
        \\        "created_at": "2023-11-24T08:39:01Z",
        \\        "updated_at": "2023-11-24T08:39:03Z",
        \\      },
        \\      {
        \\        "id": 137211749,
        \\        "node_id": "RA_kwDOEpDmIc4ILa9l",
        \\        "name": "zigmod-powerpc64le-linux",
        \\        "label": "",
        \\        "uploader": {
        \\          "login": "github-actions[bot]",
        \\          "id": 41898282,
        \\          "node_id": "MDM6Qm90NDE4OTgyODI=",
        \\          "gravatar_id": "",
        \\          "type": "Bot",
        \\          "site_admin": false
        \\        },
        \\        "content_type": "application/octet-stream",
        \\        "state": "uploaded",
        \\        "size": 11638720,
        \\        "download_count": 3,
        \\        "created_at": "2023-11-24T08:39:03Z",
        \\        "updated_at": "2023-11-24T08:39:04Z",
        \\      },
        \\      {
        \\        "id": 137211745,
        \\        "node_id": "RA_kwDOEpDmIc4ILa9h",
        \\        "name": "zigmod-riscv64-linux",
        \\        "label": "",
        \\        "uploader": {
        \\          "login": "github-actions[bot]",
        \\          "id": 41898282,
        \\          "node_id": "MDM6Qm90NDE4OTgyODI=",
        \\          "gravatar_id": "",
        \\          "type": "Bot",
        \\          "site_admin": false
        \\        },
        \\        "content_type": "application/octet-stream",
        \\        "state": "uploaded",
        \\        "size": 17282528,
        \\        "download_count": 4,
        \\        "created_at": "2023-11-24T08:38:58Z",
        \\        "updated_at": "2023-11-24T08:39:00Z",
        \\      },
        \\      {
        \\        "id": 137211752,
        \\        "node_id": "RA_kwDOEpDmIc4ILa9o",
        \\        "name": "zigmod-x86_64-linux",
        \\        "label": "",
        \\        "uploader": {
        \\          "login": "github-actions[bot]",
        \\          "id": 41898282,
        \\          "node_id": "MDM6Qm90NDE4OTgyODI=",
        \\          "gravatar_id": "",
        \\          "type": "Bot",
        \\          "site_admin": false
        \\        },
        \\        "content_type": "application/octet-stream",
        \\        "state": "uploaded",
        \\        "size": 11913416,
        \\        "download_count": 4906,
        \\        "created_at": "2023-11-24T08:39:06Z",
        \\        "updated_at": "2023-11-24T08:39:07Z",
        \\      },
        \\      {
        \\        "id": 137211733,
        \\        "node_id": "RA_kwDOEpDmIc4ILa9V",
        \\        "name": "zigmod-x86_64-macos",
        \\        "label": "",
        \\        "uploader": {
        \\          "login": "github-actions[bot]",
        \\          "id": 41898282,
        \\          "node_id": "MDM6Qm90NDE4OTgyODI=",
        \\          "gravatar_id": "",
        \\          "type": "Bot",
        \\          "site_admin": false
        \\        },
        \\        "content_type": "application/octet-stream",
        \\        "state": "uploaded",
        \\        "size": 8618320,
        \\        "download_count": 795,
        \\        "created_at": "2023-11-24T08:38:53Z",
        \\        "updated_at": "2023-11-24T08:38:54Z",
        \\      },
        \\      {
        \\        "id": 137211742,
        \\        "node_id": "RA_kwDOEpDmIc4ILa9e",
        \\        "name": "zigmod-x86_64-windows.exe",
        \\        "label": "",
        \\        "uploader": {
        \\          "login": "github-actions[bot]",
        \\          "id": 41898282,
        \\          "node_id": "MDM6Qm90NDE4OTgyODI=",
        \\          "gravatar_id": "",
        \\          "type": "Bot",
        \\          "site_admin": false
        \\        },
        \\        "content_type": "application/octet-stream",
        \\        "state": "uploaded",
        \\        "size": 7557632,
        \\        "download_count": 300,
        \\        "created_at": "2023-11-24T08:38:57Z",
        \\        "updated_at": "2023-11-24T08:38:58Z",
        \\      },
        \\      {
        \\        "id": 137211751,
        \\        "node_id": "RA_kwDOEpDmIc4ILa9n",
        \\        "name": "zigmod-x86_64-windows.pdb",
        \\        "label": "",
        \\        "uploader": {
        \\          "login": "github-actions[bot]",
        \\          "id": 41898282,
        \\          "node_id": "MDM6Qm90NDE4OTgyODI=",
        \\          "gravatar_id": "",
        \\          "type": "Bot",
        \\          "site_admin": false
        \\        },
        \\        "content_type": "application/octet-stream",
        \\        "state": "uploaded",
        \\        "size": 4411392,
        \\        "download_count": 8,
        \\        "created_at": "2023-11-24T08:39:05Z",
        \\        "updated_at": "2023-11-24T08:39:05Z",
        \\      }
        \\    ],
        \\    "body": "<li><a href='https://github.com/nektro/zigmod/commit/0df96b60dee2a9e76bf12ad8b8ab1d47dba52994'><code>0df96b6</code></a> cmd/aq/{install,update}: use proper cachepath (Meghan Denny)</li>\n<li><a href='https://github.com/nektro/zigmod/commit/a1ea508279920f457c5f899022046fefd6dc146a'><code>a1ea508</code></a> main: pass proper self_path value (Meghan Denny)</li>\n<li><a href='https://github.com/nektro/zigmod/commit/09d633b1405c5cbd4e02f4c86cb34f0368bf321f'><code>09d633b</code></a> cmd: when running zigmod inside deps folder, use parent deps folder as cachepath (Meghan Denny)</li>\n<li><a href='https://github.com/nektro/zigmod/commit/65666d00836654f33ac4405acc12ccf50f93a071'><code>65666d0</code></a> add self_name arg to all execute() call signatures (Meghan Denny)</li>\n<li><a href='https://github.com/nektro/zigmod/commit/e2d42e8ff71c3e6f534a380b7d16465fa77032f7'><code>e2d42e8</code></a> add deps.addAllLibrariesTo(), closes #84 (Meghan Denny)</li>\n<li><a href='https://github.com/nektro/zigmod/commit/f3aabb5e4e3baa7cf58af4f36f8683532d49fce3'><code>f3aabb5</code></a> regenerate deps.zig (Meghan Denny)</li>\n<li><a href='https://github.com/nektro/zigmod/commit/b8cd095ebd012788b83ac2d8e1592ce531fecde9'><code>b8cd095</code></a> mark versioned dep folders as readonly, closes #53 (Meghan Denny)</li>\n<li><a href='https://github.com/nektro/zigmod/commit/255cb974db260e67d6782f785f26604292c39131'><code>255cb97</code></a> add a buffered reader for parsing zigmod.lock (Meghan Denny)</li>\n<li><a href='https://github.com/nektro/zigmod/commit/a9863df0dedb0f59bbabcbf3d13f859e33c265a2'><code>a9863df</code></a> close some file descriptors (Meghan Denny)</li>\n<li><a href='https://github.com/nektro/zigmod/commit/941ad7c971be96e2b85a683760f0a7a3a513c202'><code>941ad7c</code></a> deps: marlersoft/zigwin32: misc confirmed update (Meghan Denny)</li>\n<li><a href='https://github.com/nektro/zigmod/commit/0e7516562fea909c18c770484919174a6e81485e'><code>0e75165</code></a> deps: nektro/zig-extras: misc confirmed updates (Meghan Denny)</li>\n<li><a href='https://github.com/nektro/zigmod/commit/8e4e9ae69d8f09d32347e7ee6c250271067f0b37'><code>8e4e9ae</code></a> deps: ziglibs/known-folders: misc confirmed updates (Meghan Denny)</li>\n<li><a href='https://github.com/nektro/zigmod/commit/8ba1d87039adee5566a0af66c3645989b976f822'><code>8ba1d87</code></a> deps: truemedian/hzzp: misc confirmed updates (Meghan Denny)</li>\n<li><a href='https://github.com/nektro/zigmod/commit/ddd0eb706c5f759141a9df462c31dbee32ef3b83'><code>ddd0eb7</code></a> deps: nektro/iguanaTLS: misc confirmed updates (Meghan Denny)</li>\n<li><a href='https://github.com/nektro/zigmod/commit/02464e094476795725f261a987c53d46da8934a3'><code>02464e0</code></a> build_release.sh: use debug mode, release breaks stack traces (Meghan Denny)</li>\n<li><a href='https://github.com/nektro/zigmod/commit/6c68f38b8cc76288dcc871b6acc5e9470385d2a7'><code>6c68f38</code></a> build.zig: add a -Doption (Meghan Denny)</li>\n<li><a href='https://github.com/nektro/zigmod/commit/5403d1a72d023253754eca1d275537ea8dc0be5a'><code>5403d1a</code></a> build.zig: move -Dtag option declaration out with other options (Meghan Denny)</li>"
        \\  }
        \\]
        \\
    );
}
