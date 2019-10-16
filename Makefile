all: riscv_config2sail

.PHONY: FORCE
FORCE:

riscv_config2sail: FORCE
	dune build src/riscv_config2sail.exe
	ln -sf _build/default/src/riscv_config2sail.exe riscv_config2sail

test: riscv_config2sail
	./riscv_config2sail -i examples/template_isa_checked.yaml -p examples/template_platform_checked.yaml -o test.sail
	sail sail/riscv_config_types.sail test.sail

clean:
	dune clean
	rm -f riscv_config2sail

