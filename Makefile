all: riscv_config2sail

riscv_config2sail:
	dune build src/riscv_config2sail.exe
	ln -s _build/default/src/riscv_config2sail.exe riscv_config2sail

clean:
	dune clean
	rm -f riscv_config2sail

