import typer

from msps.core import Msps

app = typer.Typer()


@app.command()
def switch(profile: str | None) -> None:
    # Add type hints to the switch function
    Msps().switch_to(profile)


@app.command()
def list() -> None:
    Msps().list()


if __name__ == "__main__":
    app()
