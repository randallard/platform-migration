{
  description = "Platform Migration: Monolith to Microservices Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        # Rust toolchain with WASM target
        rustToolchain = pkgs.rust-bin.stable."1.86.0".default.override {
          extensions = [ "rust-src" "rust-analyzer" ];
          targets = [ "wasm32-wasip1" ];
        };

        # Platform-specific packages
        platformPackages = with pkgs; if stdenv.isDarwin then [
          darwin.apple_sdk.frameworks.Security
          darwin.apple_sdk.frameworks.SystemConfiguration
        ] else [
          # Linux-specific packages
        ];

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Rust toolchain
            rustToolchain
            cargo-component
            cargo-watch
            cargo-edit
            cargo-audit

            # WebAssembly tools
            wasmtime
            
            # Spin CLI
            fermyon-spin

            # Database tools
            postgresql_17
            redis
            
            # Kubernetes tools
            kubectl
            kubernetes-helm
            kustomize
            argocd
            
            # Container tools
            docker
            docker-compose
            
            # Security tools
            vault
            
            # Development tools
            git
            direnv
            jq
            yq
            curl
            openssl
            
            # Node.js and Python for scripts
            nodejs_22
            python3
            python3Packages.pip
            
            # Documentation tools
            mdbook
            
            # Cloud tools
            awscli2
            terraform
            
          ] ++ platformPackages;

          shellHook = ''
            echo "🚀 Platform Migration Development Environment"
            echo "Rust: $(rustc --version)"
            echo "Spin: $(spin --version 2>/dev/null || echo 'spin not found')"
            echo "kubectl: $(kubectl version --client --short 2>/dev/null || echo 'kubectl not found')"
            echo ""
            echo "Available aliases:"
            echo "  api-build     - Build the Spin application"
            echo "  api-up        - Run the application locally"
            echo "  api-watch     - Auto-rebuild on changes"
            echo "  build-all     - Build all services"
            echo "  test-all      - Run all tests"
            echo "  fmt           - Format code"
            echo "  check         - Run clippy linter"
            echo "  clean         - Clean build artifacts"
            echo ""
            
            # Development aliases
            alias api-build='spin build'
            alias api-up='spin up --runtime-config-file runtime-config.toml'
            alias api-watch='cargo watch -x build'
            alias build-all='cargo build --workspace'
            alias test-all='cargo test --workspace'
            alias fmt='cargo fmt --all'
            alias check='cargo clippy --workspace -- -D warnings'
            alias clean='cargo clean'
            
            # Set up local database if it doesn't exist
            export PGDATA="$PWD/postgres-data"
            if [ ! -d "$PGDATA" ]; then
              echo "Setting up local PostgreSQL database..."
              initdb -D "$PGDATA" --auth-local=trust --auth-host=md5
            fi
            
            # Environment variables
            export DATABASE_URL="postgresql://postgres@localhost:5432/platform_migration"
            export REDIS_URL="redis://localhost:6379"
            export VAULT_ADDR="http://localhost:8200"
            
            # Create runtime config if it doesn't exist
            if [ ! -f runtime-config.toml ]; then
              echo "Creating runtime-config.toml from example..."
              cp runtime-config.example.toml runtime-config.toml 2>/dev/null || echo "runtime-config.example.toml not found"
            fi
          '';

          # Environment variables
          RUST_BACKTRACE = "1";
          CARGO_TARGET_WASM32_WASIP1_RUNNER = "wasmtime";
        };
      });
}