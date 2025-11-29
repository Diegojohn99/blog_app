puts "Creando usuarios y artículos de prueba..."

# Crear usuario admin
admin = User.find_or_create_by!(
  email: 'admin@blog.com'
) do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.role = :admin
end

# Crear usuario moderador
moderator = User.find_or_create_by!(
  email: 'moderator@blog.com'
) do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.role = :moderator
end

# Crear usuario regular
user = User.find_or_create_by!(
  email: 'user@blog.com'
) do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.role = :user
end

puts "Usuarios creados:"
puts "- Admin: #{admin.email} (contraseña: password123)"
puts "- Moderador: #{moderator.email} (contraseña: password123)"
puts "- Usuario: #{user.email} (contraseña: password123)"

# Crear artículos de ejemplo
articles_data = [
  {
    title: "Bienvenido al Blog",
    content: "Este es el primer artículo de nuestro blog. ¡Bienvenidos todos los lectores!",
    user: admin
  },
  {
    title: "Introducción a Rails",
    content: "Ruby on Rails es un framework de desarrollo web escrito en Ruby. Sigue el patrón MVC y convention over configuration.",
    user: moderator
  },
  {
    title: "Autenticación con Devise",
    content: "Devise es una solución de autenticación flexible para Rails basada en Warden. Proporciona módulos para diferentes necesidades de autenticación.",
    user: user
  },
  {
    title: "Autorización con CanCanCan",
    content: "CanCanCan es la continuación de CanCan, una gema de autorización para Ruby on Rails que restringe qué recursos puede acceder un usuario dado.",
    user: admin
  },
  {
    title: "Trabajando con PostgreSQL",
    content: "PostgreSQL es un sistema de base de datos objeto-relacional de código abierto conocido por su estabilidad y características avanzadas.",
    user: moderator
  }
]

articles_data.each do |article_data|
  Article.find_or_create_by!(title: article_data[:title]) do |article|
    article.content = article_data[:content]
    article.user = article_data[:user]
  end
end

puts "Creados #{Article.count} artículos de ejemplo"
puts "¡Semillas ejecutadas exitosamente!"
