describe('Login Page', () => {
  beforeEach(() => {
    cy.visit('/login')
  })

  it('should display login form', () => {
    cy.get('[data-testid=login-form]').should('be.visible')
    cy.get('[data-testid=email-input]').should('be.visible')
    cy.get('[data-testid=password-input]').should('be.visible')
    cy.get('[data-testid=login-button]').should('be.visible')
  })

  it('should login with valid credentials', () => {
    cy.get('[data-testid=email-input]').type('admin@imagentx.top')
    cy.get('[data-testid=password-input]').type('admin123')
    cy.get('[data-testid=login-button]').click()
    
    // 验证登录成功
    cy.url().should('include', '/dashboard')
    cy.get('[data-testid=user-menu]').should('be.visible')
  })

  it('should show error with invalid credentials', () => {
    cy.get('[data-testid=email-input]').type('invalid@example.com')
    cy.get('[data-testid=password-input]').type('wrongpassword')
    cy.get('[data-testid=login-button]').click()
    
    // 验证错误信息
    cy.get('[data-testid=error-message]').should('be.visible')
  })
})
