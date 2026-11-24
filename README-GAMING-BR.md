# Veyra Gaming BR — experimental (2.2.1)

Fork não oficial do Veyra. Código-fonte GPL-3.0; preserve LICENSE e avisos de terceiros. Este pacote não contém EXE compilado. O Windows, o driver NVIDIA e o hardware real não estavam disponíveis para validação.

## Alterações
- RIFE/DirectML: opções 2×, 3×, 4×, 5×, 6×; 4×–6× experimentais. Expansão dos descritores por textura e por timestep; mantém o fallback de 2× e o detector de cortes original. Multiplicadores intermediários automáticos por par desativados para RIFE; o limite de apresentação continua independente.
- Painel Gaming BR nas configurações de apresentação do modo profissional e de nós. Atalhos 60/120/144/172 FPS, perfil competitivo (sem interpolação, NR, SR, HDR, fila curta, sincronização automática), botão NIS QHD (2560×1440), ativação RIFE 2×, opção original de limite personalizado entre 1 e 1000 FPS.
- Preserva a localização pt-BR original, com ajustes pontuais. Não é uma revisão integral da tradução. A interface original continua disponível. Não foram removidos recursos ou feitos ajustes agressivos de driver.
- Ajuste na estimativa de texturas RIFE. Não constitui benchmark nem garante economia de VRAM ou FPS.

## Compilação Windows (GitHub Actions)
1. Extraia o ZIP. Crie um repositório GitHub próprio (privado se desejar testar localmente para uso pessoal; se distribuir binários, cumpra a GPL e as licenças de terceiros).
2. Envie o conteúdo da pasta Veyra-NRVideo-main, incluindo .github, para a raiz do repositório. Use git local para não perder arquivos ocultos e mantenha os arquivos binários originais.
3. Na aba Actions, habilite workflows e selecione Windows build (reproducible) > Run workflow. O workflow original usa Windows 2022, MSVC, Qt 6.8.3 e dependências fixadas, com etapa acrescentada para cabeçalhos RIFE e DLLs DirectML. O workflow não foi executado aqui; podem ocorrer erros de dependências, quotas ou compilação.
4. Se concluído, baixe o artifact `veyra-windows-ci-no-gpu-runtimes` da execução (nome histórico), descompacte seu ZIP e execute `veyra_qml_ui.exe`. Mantenha toda a pasta junta. Não substitua DLLs de uma instalação oficial de outra versão.
5. Para RIFE: coloque os dois modelos `rife_v4.26_fp16.onnx` e `rife_v4.22_lite_fp16.onnx` dentro de `runtime/rife` ao lado do EXE. As DLLs deverão vir do workflow, mas os modelos NÃO vêm neste ZIP. O arquivo `docs/RIFE_DIRECTML.md` descreve a origem e conversão dos modelos. Com Python instalado, instale `onnx` e `onnxruntime`, extraia os dois arquivos 7z do release external-models do vs-mlrt em uma pasta que contenha `rife_v2`, e execute `python tools/rife_models/make_rife_models.py <pasta> <pasta-do-exe>/runtime/rife`. Use apenas fontes oficiais e não sobrescreva uma instalação de produção. A documentação upstream descreve medições apenas de 2×/3×, não desta modificação.
6. Compilação local alternativa: prepare os SDKs conforme workflow e docs originais; execute `powershell -ExecutionPolicy Bypass -File scripts/ci/fetch-rife-gaming.ps1 -Root .` antes de configurar CMake. O script `scripts/build.ps1` exige Visual Studio 2022 e dependências indicadas no projeto.

## Teste recomendado — GTX 1660 Ti 6GB, i7-10750H, 16GB
- Use o notebook na tomada, Windows em modo de desempenho e GPU NVIDIA dedicada; monitor configurado em 175 Hz no Windows. Não altere clocks.
- Abra a captura/PS Remote Play conforme sua instalação. SDR (RIFE não funciona em HDR). Perfil competitivo primeiro, sem FG; verifique FPS real e atraso.
- Selecione RIFE 2×, fonte 30 FPS e sem NIS. Verifique estabilidade e VRAM; depois 3×, 4×, 5×, 6×. O painel de FG original permite selecionar o multiplicador. 30×6=180 é uma taxa teórica; defina 172 no limite personalizado ou no atalho. O apresentador limita a saída, mas não garante 172 quadros distintos/s, e o sistema pode reduzir ou pular geração sob carga.
- Para 1440p, tente NIS em QHD depois de medir RIFE sem upscale. Processamento em resolução maior pode diminuir muito o FPS. Fonte de captura 1080p é um ponto de partida, sem garantia de 120 FPS. Em jogos competitivos, priorize menor atraso e quadros reais.
- GTX 1660 Ti não é RTX; VFG/DLSS FG não foram desbloqueados artificialmente. A GTX pode usar DirectML, mas 6× em 1440p/tempo real não foi comprovado. A captura nativa não é modificada. Interpolação pode introduzir artefatos e atraso.

## Validação realizada
- Smoke test C++20 `tests/gaming-br/RateSmoke.cpp`, compilado com g++ no Linux: PASS (seleção 2–6×, rejeição 7×, alvo 172, validação e grade temporal do limite).
- Testes de contrato upstream foram ajustados para aceitar 4–6× RIFE. Não executados integralmente.
- Não executados: build Windows, QML, DirectML, captura PS5, estabilidade, qualidade, uso GPU/CPU/RAM ou FPS reais. Não considere este pacote release estável.
