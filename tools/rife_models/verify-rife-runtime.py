# SPDX-License-Identifier: GPL-3.0-only
"""Check the model interface used by RifeDmlBackend (not GPU inference)."""
from pathlib import Path
import sys
import onnx
from onnx import TensorProto

for name in ('rife_v4.26', 'rife_v4.22_lite'):
    path = Path(sys.argv[1]) / (name + '_fp16.onnx')
    graph = onnx.load(path, load_external_data=False).graph
    assert {x.name for x in graph.input} == {'img0', 'img1', 'timestep'}, path
    for x in graph.input:
        t = x.type.tensor_type
        assert t.elem_type == TensorProto.FLOAT, (path, x.name)
        dims = t.shape.dim
        assert len(dims) == 4 and dims[0].dim_value == 1, (path, x.name)
        assert dims[1].dim_value == (1 if x.name == 'timestep' else 3), (path, x.name)
        assert [d.dim_param for d in dims[2:]] == ['height', 'width'], (path, x.name)
    assert len(graph.output) == 1 and graph.output[0].name == 'output', path
    assert graph.output[0].type.tensor_type.elem_type == TensorProto.FLOAT, path
    assert not any(t.data_location == TensorProto.EXTERNAL for t in graph.initializer), path
    print(f'Interface OK: {path.name} ({path.stat().st_size:,} bytes)')
