from typer.testing import CliRunner

from msps.cli import app


def test_cli_imports() -> None:
    """Verify msps.cli and its typer dependency are importable."""
    assert app is not None


def test_cli_help() -> None:
    """Verify the main CLI entry point shows both subcommands."""
    runner = CliRunner()
    result = runner.invoke(app, ["--help"])
    assert result.exit_code == 0
    assert "switch" in result.output
    assert "list" in result.output


def test_switch_help() -> None:
    """Verify the switch subcommand responds to --help without touching the filesystem."""
    runner = CliRunner()
    result = runner.invoke(app, ["switch", "--help"])
    assert result.exit_code == 0


def test_list_help() -> None:
    """Verify the list subcommand responds to --help without touching the filesystem."""
    runner = CliRunner()
    result = runner.invoke(app, ["list", "--help"])
    assert result.exit_code == 0
