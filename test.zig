const std = @import("std");
const json = @import("json");

fn parse_full(buffer: []const u8) !void {
    const alloc = std.testing.allocator;
    var fbs = std.io.fixedBufferStream(buffer);
    var doc = try json.parse(alloc, "", fbs.reader(), .{ .support_trailing_commas = true, .maximum_depth = 100 });
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

const JSONTestSuite_root = ".zigmod/deps/v/git/github.com/nst/JSONTestSuite/commit-984defc2deaa653cb73cd29f4144a720ec9efe7c/test_parsing";

fn expectPass(path: []const u8) !void {
    const alloc = std.testing.allocator;
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    var doc = try json.parse(alloc, path, file.reader(), .{ .support_trailing_commas = false, .maximum_depth = 100 });
    defer doc.deinit(alloc);
}

// zig fmt: off
test { try expectPass(JSONTestSuite_root ++ "/y_array_arraysWithSpaces.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_array_empty.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_array_empty-string.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_array_ending_with_newline.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_array_false.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_array_heterogeneous.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_array_null.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_array_with_1_and_newline.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_array_with_leading_space.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_array_with_several_null.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_array_with_trailing_space.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_number_0e+1.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_number_0e1.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_number_after_space.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_number_double_close_to_zero.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_number_int_with_exp.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_number.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_number_minus_zero.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_number_negative_int.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_number_negative_one.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_number_negative_zero.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_number_real_capital_e.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_number_real_capital_e_neg_exp.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_number_real_capital_e_pos_exp.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_number_real_exponent.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_number_real_fraction_exponent.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_number_real_neg_exp.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_number_real_pos_exponent.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_number_simple_int.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_number_simple_real.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_object_basic.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_object_duplicated_key_and_value.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_object_duplicated_key.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_object_empty.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_object_empty_key.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_object_escaped_null_in_key.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_object_extreme_numbers.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_object.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_object_long_strings.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_object_simple.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_object_string_unicode.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_object_with_newlines.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_1_2_3_bytes_UTF-8_sequences.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_accepted_surrogate_pair.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_accepted_surrogate_pairs.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_allowed_escapes.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_backslash_and_u_escaped_zero.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_backslash_doublequotes.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_comments.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_double_escape_a.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_double_escape_n.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_escaped_control_character.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_escaped_noncharacter.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_in_array.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_in_array_with_leading_space.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_last_surrogates_1_and_2.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_nbsp_uescaped.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_nonCharacterInUTF-8_U+10FFFF.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_nonCharacterInUTF-8_U+FFFF.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_null_escape.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_one-byte-utf-8.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_pi.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_reservedCharacterInUTF-8_U+1BFFF.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_simple_ascii.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_space.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_surrogates_U+1D11E_MUSICAL_SYMBOL_G_CLEF.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_three-byte-utf-8.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_two-byte-utf-8.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_u+2028_line_sep.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_u+2029_par_sep.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_uescaped_newline.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_uEscape.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_unescaped_char_delete.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_unicode_2.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_unicodeEscapedBackslash.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_unicode_escaped_double_quote.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_unicode.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_unicode_U+10FFFE_nonchar.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_unicode_U+1FFFE_nonchar.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_unicode_U+200B_ZERO_WIDTH_SPACE.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_unicode_U+2064_invisible_plus.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_unicode_U+FDD0_nonchar.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_unicode_U+FFFE_nonchar.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_utf8.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_string_with_del_character.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_structure_lonely_false.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_structure_lonely_int.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_structure_lonely_negative_real.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_structure_lonely_null.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_structure_lonely_string.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_structure_lonely_true.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_structure_string_empty.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_structure_trailing_newline.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_structure_true_in_array.json"); }
test { try expectPass(JSONTestSuite_root ++ "/y_structure_whitespace_array.json"); }
// zig fmt: on

fn expectFail(path: []const u8) !void {
    const alloc = std.testing.allocator;
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    var doc = json.parse(alloc, path, file.reader(), .{ .support_trailing_commas = false, .maximum_depth = 100 }) catch return;
    defer doc.deinit(alloc);
    try std.testing.expect(false);
}

// zig fmt: off
test { try expectFail(JSONTestSuite_root ++ "/n_array_1_true_without_comma.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_array_a_invalid_utf8.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_array_colon_instead_of_comma.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_array_comma_after_close.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_array_comma_and_number.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_array_double_comma.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_array_double_extra_comma.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_array_extra_close.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_array_extra_comma.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_array_incomplete_invalid_value.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_array_incomplete.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_array_inner_array_no_comma.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_array_invalid_utf8.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_array_items_separated_by_semicolon.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_array_just_comma.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_array_just_minus.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_array_missing_value.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_array_newlines_unclosed.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_array_number_and_comma.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_array_number_and_several_commas.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_array_spaces_vertical_tab_formfeed.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_array_star_inside.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_array_unclosed.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_array_unclosed_trailing_comma.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_array_unclosed_with_new_lines.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_array_unclosed_with_object_inside.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_incomplete_false.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_incomplete_null.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_incomplete_true.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_multidigit_number_then_00.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_0.1.2.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_-01.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_0.3e+.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_0.3e.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_0_capital_E+.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_0_capital_E.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_0.e1.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_0e+.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_0e.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_1_000.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_1.0e+.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_1.0e-.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_1.0e.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_-1.0..json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_1eE2.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_+1.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_.-1.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_2.e+3.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_2.e-3.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_2.e3.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_.2e-3.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_-2..json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_9.e+.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_expression.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_hex_1_digit.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_hex_2_digits.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_infinity.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_+Inf.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_Inf.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_invalid+-.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_invalid-negative-real.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_invalid-utf-8-in-bigger-int.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_invalid-utf-8-in-exponent.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_invalid-utf-8-in-int.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_++.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_minus_infinity.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_minus_sign_with_trailing_garbage.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_minus_space_1.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_-NaN.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_NaN.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_neg_int_starting_with_zero.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_neg_real_without_int_part.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_neg_with_garbage_at_end.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_real_garbage_after_e.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_real_with_invalid_utf8_after_e.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_real_without_fractional_part.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_starting_with_dot.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_U+FF11_fullwidth_digit_one.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_with_alpha_char.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_with_alpha.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_number_with_leading_zero.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_object_bad_value.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_object_bracket_key.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_object_comma_instead_of_colon.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_object_double_colon.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_object_emoji.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_object_garbage_at_end.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_object_key_with_single_quotes.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_object_lone_continuation_byte_in_key_and_trailing_comma.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_object_missing_colon.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_object_missing_key.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_object_missing_semicolon.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_object_missing_value.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_object_no-colon.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_object_non_string_key_but_huge_number_instead.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_object_non_string_key.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_object_repeated_null_null.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_object_several_trailing_commas.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_object_single_quote.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_object_trailing_comma.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_object_trailing_comment.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_object_trailing_comment_open.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_object_trailing_comment_slash_open_incomplete.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_object_trailing_comment_slash_open.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_object_two_commas_in_a_row.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_object_unquoted_key.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_object_unterminated-value.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_object_with_single_string.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_object_with_trailing_garbage.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_single_space.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_string_1_surrogate_then_escape.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_string_1_surrogate_then_escape_u1.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_string_1_surrogate_then_escape_u1x.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_string_1_surrogate_then_escape_u.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_string_accentuated_char_no_quotes.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_string_backslash_00.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_string_escaped_backslash_bad.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_string_escaped_ctrl_char_tab.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_string_escaped_emoji.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_string_escape_x.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_string_incomplete_escaped_character.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_string_incomplete_escape.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_string_incomplete_surrogate_escape_invalid.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_string_incomplete_surrogate.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_string_invalid_backslash_esc.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_string_invalid_unicode_escape.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_string_invalid_utf8_after_escape.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_string_invalid-utf-8-in-escape.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_string_leading_uescaped_thinspace.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_string_no_quotes_with_bad_escape.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_string_single_doublequote.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_string_single_quote.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_string_single_string_no_double_quotes.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_string_start_escape_unclosed.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_string_unescaped_ctrl_char.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_string_unescaped_newline.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_string_unescaped_tab.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_string_unicode_CapitalU.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_string_with_trailing_garbage.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_100000_opening_arrays.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_angle_bracket_..json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_angle_bracket_null.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_array_trailing_garbage.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_array_with_extra_array_close.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_array_with_unclosed_string.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_ascii-unicode-identifier.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_capitalized_True.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_close_unopened_array.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_comma_instead_of_closing_brace.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_double_array.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_end_array.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_incomplete_UTF8_BOM.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_lone-invalid-utf-8.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_lone-open-bracket.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_no_data.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_null-byte-outside-string.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_number_with_trailing_garbage.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_object_followed_by_closing_object.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_object_unclosed_no_value.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_object_with_comment.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_object_with_trailing_garbage.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_open_array_apostrophe.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_open_array_comma.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_open_array_object.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_open_array_open_object.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_open_array_open_string.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_open_array_string.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_open_object_close_array.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_open_object_comma.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_open_object.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_open_object_open_array.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_open_object_open_string.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_open_object_string_with_apostrophes.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_open_open.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_single_eacute.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_single_star.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_trailing_#.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_U+2060_word_joined.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_uescaped_LF_before_string.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_unclosed_array.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_unclosed_array_partial_null.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_unclosed_array_unfinished_false.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_unclosed_array_unfinished_true.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_unclosed_object.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_unicode-identifier.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_UTF8_BOM_no_data.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_whitespace_formfeed.json"); }
test { try expectFail(JSONTestSuite_root ++ "/n_structure_whitespace_U+2060_word_joiner.json"); }
// zig fmt: on
