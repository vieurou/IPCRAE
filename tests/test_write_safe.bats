#!/usr/bin/env bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

setup() {
  TEST_DIR="$(mktemp -d)"
  export DRY_RUN=false
  export SCRIPT_DIR="$PWD"
  
  # Source the functions directly to test them
  source ./ipcrae-install.sh --version >/dev/null 2>&1 || true
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "write_safe writes content from argument" {
  local test_file="$TEST_DIR/test1.txt"
  write_safe "$test_file" "Contenu test"
  
  [ -f "$test_file" ]
  run cat "$test_file"
  [ "$output" = "Contenu test" ]
}

@test "write_safe writes content from stdin (heredoc)" {
  local test_file="$TEST_DIR/test2.txt"
  write_safe "$test_file" <<EOF
Ligne 1
Ligne 2
EOF
  
  [ -f "$test_file" ]
  run cat "$test_file"
  echo "$output" | grep "Ligne 1"
  echo "$output" | grep "Ligne 2"
}

@test "write_safe handles empty content gracefully via stdin without hanging" {
  local test_file="$TEST_DIR/test3.txt"
  
  # Si on passe /dev/null comme stdin, ça simule un flux vide non-interactif
  write_safe "$test_file" </dev/null
  
  [ -f "$test_file" ]
  run cat "$test_file"
  [ -z "$output" ]
}

@test "write_safe logs and skips execution in DRY_RUN mode" {
  export DRY_RUN=true
  local test_file="$TEST_DIR/dryrun.txt"
  
  run write_safe "$test_file" "Ne pas ecrire"
  
  [ ! -f "$test_file" ]
  echo "$output" | grep "\[DRY-RUN\]"
}

@test "normalize_root correctly expands paths" {
  run normalize_root "~"
  [ "$output" = "$HOME" ]
  
  run normalize_root "~/test"
  [ "$output" = "$HOME/test" ]
  
  run normalize_root "/etc/var/"
  [ "$output" = "/etc/var" ]
  
  run normalize_root "/"
  [ "$output" = "/" ]
}

@test "prompt_yes_no respects AUTO_YES=true" {
  export AUTO_YES=true
  run prompt_yes_no "Test question ?" "y"
  [ "$status" -eq 0 ]
}
