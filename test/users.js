let chai = require('chai')
let chaiHttp = require('chai-http')
let server = require('../app')
let should = chai.should()

chai.use(chaiHttp)

describe('Users', () => {
  it('it should have some users', (done) => {
    chai.request(server)
        .get('/users')
        .end((err, res) => {
          res.should.have.status(200)
          res.body.should.be.a('array')
          res.body.length.should.be.gt(0)
          res.body[0].should.have.property('firstname')
          res.body[0].should.have.property('lastname')
          done()
        })
  })
})
