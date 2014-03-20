module.exports = 
  development:
    driver: "mongoose"
    url: "mongodb://localhost/chantbox-development"

  test:
    driver: "mongoose"
    url: "mongodb://localhost/chantbox-test"

  production:
    driver: "mongoose"
    url: process.env.MONGOHQ_URL
