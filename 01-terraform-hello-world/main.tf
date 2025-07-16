resource "local_file" "pet" {
    filename = "/workspaces/curso-terraform/pets.txt"
    content = "We love pets! Hola desde la version 2"
}