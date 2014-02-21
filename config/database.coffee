module.exports = 
  development:
    driver: "mongoose"
    url: "mongodb://localhost/chantbox-development"

  test:
    driver: "mongoose"
    url: "mongodb://localhost/chantbox-test"

  production:
    driver: "mongoose"
    url: "mongodb://heroku:41e124bdb8f34a7c7c43017891725fbe@troup.mongohq.com:10004/app22419266"
