"""Smoke test: valida que docker-compose.yml y .env.example estén sanos.

No levanta contenedores; solo verifica sintaxis y presencia de variables.
"""
from pathlib import Path

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
    assert "appendonly yes" in conf, "redis.conf sin AOF"


def test_redis_conf_has_no_requirepass_directive():
    """redis-server no expande variables: requirepass va por `command`, no en el .conf."""
    conf = (REPO / "redis" / "redis.conf").read_text()
    directives = [
        line.strip()
        for line in conf.splitlines()
        if line.strip() and not line.lstrip().startswith("#")
    ]
    assert not any(line.startswith("requirepass") for line in directives), (
        "redis.conf define requirepass (no expande ${REDIS_PASSWORD})"
    )


def test_redis_password_passed_via_command():
    """La password debe llegar expandida al redis-server del contenedor."""
    compose = (REPO / "docker-compose.yml").read_text()
    assert "--requirepass" in compose, "redis no recibe --requirepass"
    assert "$$REDIS_PASSWORD" in compose, "usar $$ para expandir en el contenedor, no en Compose"


def test_redis_healthcheck_uses_auth():
    """Con password, el healthcheck debe autenticar."""
    compose = (REPO / "docker-compose.yml").read_text()
    assert "REDISCLI_AUTH" in compose and "REDIS_PASSWORD" in compose, (
        "healthcheck de redis no autentica con password"
    )
