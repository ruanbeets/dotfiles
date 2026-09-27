function gpu --description 'One-shot NVIDIA summary (no polling)'
    if not type -q nvidia-smi
        printf 'nvidia-smi is unavailable; try nvtop for supported GPUs.\n' >&2
        return 127
    end
    command nvidia-smi --query-gpu=name,utilization.gpu,memory.used,memory.total,temperature.gpu,power.draw --format=csv $argv
end
