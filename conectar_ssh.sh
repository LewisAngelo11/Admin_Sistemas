conectar_servidor() {
    local usuario=$1
    local servidor=$2
    ssh "${usuario}@${servidor}"
}