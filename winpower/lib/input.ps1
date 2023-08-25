
# Cast a value into integer. If fails returns $null
function castInt($val) {
    try {
        return [int] $val;
    } catch {
        return $nulll;
    }
}