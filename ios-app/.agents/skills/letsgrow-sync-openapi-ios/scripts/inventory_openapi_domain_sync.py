#!/usr/bin/env python3
from __future__ import annotations

import re
from pathlib import Path


ROOT = Path.cwd()
CLIENT_PATH = ROOT / "Modules/Sources/OpenAPI/GeneratedSources/Client.swift"
API_CLIENT_PATH = ROOT / "Modules/Sources/Domain/Services/ApiClient.swift"
DOMAIN_API_DIR = ROOT / "Modules/Sources/Domain/Models/API"
DOMAIN_ERROR_DIR = ROOT / "Modules/Sources/Domain/Errors"
MAPPERS_DIR = ROOT / "Modules/Sources/Adapters/APIClient/Mappers"
LIVE_DIR = ROOT / "Modules/Sources/Adapters/APIClient/Live"
LIVE_ENTRY_PATH = LIVE_DIR / "APIClient+Live.swift"
APP_MOCK_PATH = ROOT / "AppMock/ApiClientMock.swift"
LOCAL_ONLY_API_CLIENT_MEMBERS = {
    "sessionChangedListener",
    "createEvent",
    "updateEvent",
    "deleteEvent",
    "joinEvent",
    "markEventAsSeen",
}


def read(path: Path) -> str:
    if not path.exists():
        return ""
    return path.read_text()


def unique_preserving_order(values: list[str]) -> list[str]:
    seen: set[str] = set()
    ordered: list[str] = []
    for value in values:
        if value in seen:
            continue
        seen.add(value)
        ordered.append(value)
    return ordered


def extract_generated_client_methods(text: str) -> list[str]:
    return unique_preserving_order(re.findall(r"public func ([A-Za-z0-9_]+)\(", text))


def extract_client_schema_names(text: str) -> list[str]:
    return unique_preserving_order(re.findall(r"Components\.Schemas\.([A-Z][A-Za-z0-9_]+)", text))


def extract_api_client_methods(text: str) -> list[str]:
    return re.findall(r"public var ([A-Za-z0-9_]+):", text)


def extract_public_type_names(directory: Path) -> list[str]:
    pattern = re.compile(r"public (?:struct|enum|class|actor|protocol|typealias) ([A-Z][A-Za-z0-9_]+)")
    results: list[str] = []
    if not directory.exists():
        return results
    for file_path in sorted(directory.rglob("*.swift")):
        results.extend(pattern.findall(read(file_path)))
    return sorted(set(results))


def extract_mapping_stems(directory: Path) -> list[str]:
    if not directory.exists():
        return []
    stems = []
    for file_path in sorted(directory.rglob("*+Mapping.swift")):
        stems.append(file_path.name.removesuffix("+Mapping.swift"))
    return sorted(set(stems))


def extract_initializer_labels(text: str) -> list[str]:
    return unique_preserving_order(
        re.findall(r"^\s{12}([A-Za-z0-9_]+):", text, flags=re.MULTILINE)
    )


def extract_live_factory_methods(directory: Path) -> list[str]:
    if not directory.exists():
        return []
    methods: list[str] = []
    for file_path in sorted(directory.rglob("*.swift")):
        methods.extend(re.findall(r"static func (make[A-Za-z0-9_]+)\(", read(file_path)))
    return unique_preserving_order(methods)


def expected_factory_name(api_client_member: str) -> str:
    return f"make{api_client_member[:1].upper()}{api_client_member[1:]}"


def print_section(title: str, values: list[str]) -> None:
    print(title)
    if not values:
        print("  (none)")
        return
    for value in values:
        print(f"  - {value}")


def main() -> None:
    client_text = read(CLIENT_PATH)
    api_client_text = read(API_CLIENT_PATH)
    live_entry_text = read(LIVE_ENTRY_PATH)
    app_mock_text = read(APP_MOCK_PATH)

    generated_methods = extract_generated_client_methods(client_text)
    client_schema_names = extract_client_schema_names(client_text)
    api_client_methods = extract_api_client_methods(api_client_text)
    domain_api_types = sorted(
        set(extract_public_type_names(DOMAIN_API_DIR) + extract_public_type_names(DOMAIN_ERROR_DIR))
    )
    mapper_stems = extract_mapping_stems(MAPPERS_DIR)
    live_initializer_labels = extract_initializer_labels(live_entry_text)
    app_mock_initializer_labels = extract_initializer_labels(app_mock_text)
    live_factory_methods = extract_live_factory_methods(LIVE_DIR)

    missing_api_client = [name for name in generated_methods if name not in api_client_methods]
    extra_api_client = [
        name for name in api_client_methods
        if name not in generated_methods and name not in LOCAL_ONLY_API_CLIENT_MEMBERS
    ]
    missing_domain_api_types = [name for name in client_schema_names if name not in domain_api_types]
    missing_mapper_stems = [name for name in client_schema_names if name not in mapper_stems]
    missing_live_initializer_labels = [name for name in generated_methods if name not in live_initializer_labels]
    extra_live_initializer_labels = [
        name for name in live_initializer_labels
        if name not in generated_methods and name not in LOCAL_ONLY_API_CLIENT_MEMBERS
    ]
    missing_app_mock_initializer_labels = [name for name in generated_methods if name not in app_mock_initializer_labels]
    extra_app_mock_initializer_labels = [
        name for name in app_mock_initializer_labels
        if name not in generated_methods and name not in LOCAL_ONLY_API_CLIENT_MEMBERS
    ]
    expected_live_factories = [expected_factory_name(name) for name in live_initializer_labels]
    missing_live_factories = [name for name in expected_live_factories if name not in live_factory_methods]

    print_section("Generated client methods", generated_methods)
    print()
    print_section("Domain APIClient methods", api_client_methods)
    print()
    print_section("Missing APIClient methods", missing_api_client)
    print()
    print_section("Extra APIClient methods", extra_api_client)
    print()
    print_section("Client.swift referenced schema names", client_schema_names)
    print()
    print_section("Current handwritten Domain API public types", domain_api_types)
    print()
    print_section(
        "Client.swift schema names without same-named Domain API type",
        missing_domain_api_types,
    )
    print()
    print_section("Current mapper stems", mapper_stems)
    print()
    print_section(
        "Client.swift schema names without same-named mapper file",
        missing_mapper_stems,
    )
    print()
    print_section("Live initializer labels", live_initializer_labels)
    print()
    print_section("Missing Live initializer labels", missing_live_initializer_labels)
    print()
    print_section("Extra Live initializer labels", extra_live_initializer_labels)
    print()
    print_section("Live factory helpers", live_factory_methods)
    print()
    print_section(
        "Live initializer labels without matching make* helper",
        missing_live_factories,
    )
    print()
    print_section("AppMock initializer labels", app_mock_initializer_labels)
    print()
    print_section(
        "Missing AppMock initializer labels",
        missing_app_mock_initializer_labels,
    )
    print()
    print_section(
        "Extra AppMock initializer labels",
        extra_app_mock_initializer_labels,
    )


if __name__ == "__main__":
    main()
