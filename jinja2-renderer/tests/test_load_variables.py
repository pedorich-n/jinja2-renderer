from jinja2_renderer.renderer import load_variables


def test_loading_multiple_files(tmp_path):
    file1 = tmp_path / "file1.json"
    file2 = tmp_path / "file2.json"
    file3 = tmp_path / "file3.json"

    file1.write_text("""{"a": 1, "b": 2, "c": 3}""")
    file2.write_text("""{"c": 10, "d": 4, "e": 5}""")
    file3.write_text("""{"a": 11, "f": 6, "g": 7}""")

    files = [file1, file2, file3]
    result = load_variables(files)

    expected = {"a": 11, "b": 2, "c": 10, "d": 4, "e": 5, "f": 6, "g": 7}

    assert result == expected
