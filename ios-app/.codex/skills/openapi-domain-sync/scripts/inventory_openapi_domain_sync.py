#!/usr/bin/env python3
from __future__ import annotations

import re
from pathlib import Path


ROOT = Path.cwd()
CLIENT_PATH = ROOT / "Modules/Sources/OpenAPI/GeneratedSources/Client.swift"
TYPES_PATH = ROOT / "Modules/Sources/OpenAPI/GeneratedSources/Types.swift"
API_CLIENT_PATH = ROOT / "Modules/Sources/Domain/Services/ApiClient.swift"
DOMAIN_DIRS = [
    ROOT / "Modules/Sources/Domain/Models",
    ROOT / "Modules/Sources/Domain/Errors",
    ROOT / "Modules/Sources/Domain/Services",
]


def read(path: Path) -> str:
    return path.read_text()


def extract_generated_client_methods(text: str) -> list[str]:
    methods = re.findall(r"public func ([A-Za-z0-9_]+)\(", text)
    seen: set[str] = set()
    ordered: list[str] = []
    for method in methods:
        if method not in seen:
            seen.add(method)
            ordered.append(method)
    return ordered


def extract_api_client_methods(text: str) -> list[str]:
    return re.findall(r"public var ([A-Za-z0-9_]+):", text)


def extract_domain_public_types() -> list[str]:
    pattern = re.compile(r"public (?:struct|enum|class|actor|protocol) ([A-Z][A-Za-z0-9_]+)")
    results: list[str] = []
    for directory in DOMAIN_DIRS:
        if not directory.exists():
            continue
        for file_path in sorted(directory.rglob("*.swift")):
            results.extend(pattern.findall(read(file_path)))
    return sorted(set(results))


def extract_top_level_schema_names(text: str) -> list[str]:
    lines = text.splitlines()
    brace_depth = 0
    in_schemas = False
    schemas_depth = -1
    names: list[str] = []
    seen: set[str] = set()

    for line in lines:
        stripped = line.strip()

        if stripped.startswith("public enum Schemas {"):
            in_schemas = True
            schemas_depth = brace_depth
        elif in_schemas and brace_depth == schemas_depth + 1:
            match = re.match(r"public (?:struct|enum) ([A-Z][A-Za-z0-9_]+)", stripped)
            if match and match.group(1) not in seen:
                seen.add(match.group(1))
                names.append(match.group(1))

        brace_depth += line.count("{")
        brace_depth -= line.count("}")

        if in_schemas and brace_depth <= schemas_depth:
            in_schemas = False

    return names


def print_section(title: str, values: list[str]) -> None:
    print(title)
    if not values:
        print("  (none)")
        return
    for value in values:
        print(f"  - {value}")


def main() -> None:
    generated_methods = extract_generated_client_methods(read(CLIENT_PATH))
    api_client_methods = extract_api_client_methods(read(API_CLIENT_PATH))
    domain_types = extract_domain_public_types()
    schema_names = extract_top_level_schema_names(read(TYPES_PATH))

    missing_api_client = [name for name in generated_methods if name not in api_client_methods]
    extra_api_client = [name for name in api_client_methods if name not in generated_methods]
    missing_domain_types = [name for name in schema_names if name not in domain_types]

    print_section("Generated client methods", generated_methods)
    print()
    print_section("Domain APIClient methods", api_client_methods)
    print()
    print_section("Missing APIClient methods", missing_api_client)
    print()
    print_section("Extra APIClient methods", extra_api_client)
    print()
    print_section("Top-level generated schema names", schema_names)
    print()
    print_section("Current handwritten Domain public types", domain_types)
    print()
    print_section(
        "Generated schema names without same-named Domain type",
        missing_domain_types,
    )


if __name__ == "__main__":
    main()
