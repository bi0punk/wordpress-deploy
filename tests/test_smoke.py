"""Smoke test: valida que docker-compose.yml y .env.example estén sanos.

No levanta contenedores; solo verifica sintaxis y presencia de variables.
"""
from pathlib import Path
from shutil import which

import pytest

REPO = Path(__file__).resolve().parent.parent


def test_readme_and_gitignore():
    assert (REPO / "README.md").exists()
    assert (REPO / ".gitignore").exists()


def test_env_example_exists():
    assert (REPO / ".env.example").exists(), "Falta .env.example"


def test_compose_file_exists():
    assert (REPO / "docker-compose.yml").exists()


def test_compose_config_validates():
    pytest.importorskip("yaml")
    import yaml

    compose = yaml.safe_load((REPO / "docker-compose.yml").read_text())
    assert "services" in compose
    for required in ("mariadb", "wordpress", "nginx", "redis"):
        assert required in compose["services"], f"Falta servicio {required}"


def test_redis_conf_no_loopback_bind():
    """Redis en Docker NO debe bind 127.0.0.1 (rompe acceso entre contenedores)."""
    conf = (REPO / "redis" / "redis.conf").read_text()
    assert "bind 127.0.0.1" not in conf, "redis.conf usa bind 127.0.0.1 (rompe WP)"
    assert "requirepass" in conf, "redis.conf sin requirepass"


def test_redis_healthcheck_uses_auth():
    """Con requirepass, el healthcheck debe autenticar."""
    compose = (REPO / "docker-compose.yml").read_text()
    assert "-a" in compose and "REDIS_PASSWORD" in compose, (
        "healthcheck de redis no autentica con password"
    )
