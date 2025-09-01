import React from 'react'
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom'
import LoginForm from '../../components/LoginForm'

// Mock next/router
jest.mock('next/router', () => ({
  useRouter() {
    return {
      push: jest.fn(),
      replace: jest.fn(),
      prefetch: jest.fn().mockResolvedValue(undefined),
    }
  },
}))

// Mock API calls
jest.mock('../../services/auth', () => ({
  login: jest.fn(),
}))

describe('LoginForm Component', () => {
  const mockLogin = require('../../services/auth').login

  beforeEach(() => {
    jest.clearAllMocks()
  })

  it('should render login form with all required fields', () => {
    render(<LoginForm />)

    expect(screen.getByTestId('login-form')).toBeInTheDocument()
    expect(screen.getByTestId('email-input')).toBeInTheDocument()
    expect(screen.getByTestId('password-input')).toBeInTheDocument()
    expect(screen.getByTestId('login-button')).toBeInTheDocument()
  })

  it('should display validation errors for empty fields', async () => {
    render(<LoginForm />)

    const loginButton = screen.getByTestId('login-button')
    fireEvent.click(loginButton)

    await waitFor(() => {
      expect(screen.getByText('Email is required')).toBeInTheDocument()
      expect(screen.getByText('Password is required')).toBeInTheDocument()
    })
  })

  it('should display validation error for invalid email', async () => {
    render(<LoginForm />)

    const emailInput = screen.getByTestId('email-input')
    fireEvent.change(emailInput, { target: { value: 'invalid-email' } })

    const loginButton = screen.getByTestId('login-button')
    fireEvent.click(loginButton)

    await waitFor(() => {
      expect(screen.getByText('Please enter a valid email')).toBeInTheDocument()
    })
  })

  it('should call login API with correct data on valid form submission', async () => {
    mockLogin.mockResolvedValueOnce({
      success: true,
      token: 'test-token',
      user: { id: 1, email: 'test@example.com' }
    })

    render(<LoginForm />)

    const emailInput = screen.getByTestId('email-input')
    const passwordInput = screen.getByTestId('password-input')
    const loginButton = screen.getByTestId('login-button')

    fireEvent.change(emailInput, { target: { value: 'test@example.com' } })
    fireEvent.change(passwordInput, { target: { value: 'password123' } })
    fireEvent.click(loginButton)

    await waitFor(() => {
      expect(mockLogin).toHaveBeenCalledWith({
        email: 'test@example.com',
        password: 'password123'
      })
    })
  })

  it('should display error message when login fails', async () => {
    mockLogin.mockRejectedValueOnce(new Error('Invalid credentials'))

    render(<LoginForm />)

    const emailInput = screen.getByTestId('email-input')
    const passwordInput = screen.getByTestId('password-input')
    const loginButton = screen.getByTestId('login-button')

    fireEvent.change(emailInput, { target: { value: 'test@example.com' } })
    fireEvent.change(passwordInput, { target: { value: 'wrongpassword' } })
    fireEvent.click(loginButton)

    await waitFor(() => {
      expect(screen.getByText('Login failed. Please check your credentials.')).toBeInTheDocument()
    })
  })

  it('should show loading state during login process', async () => {
    mockLogin.mockImplementation(() => new Promise(resolve => setTimeout(resolve, 100)))

    render(<LoginForm />)

    const emailInput = screen.getByTestId('email-input')
    const passwordInput = screen.getByTestId('password-input')
    const loginButton = screen.getByTestId('login-button')

    fireEvent.change(emailInput, { target: { value: 'test@example.com' } })
    fireEvent.change(passwordInput, { target: { value: 'password123' } })
    fireEvent.click(loginButton)

    expect(screen.getByText('Logging in...')).toBeInTheDocument()
    expect(loginButton).toBeDisabled()
  })

  it('should toggle password visibility when eye icon is clicked', () => {
    render(<LoginForm />)

    const passwordInput = screen.getByTestId('password-input')
    const toggleButton = screen.getByTestId('password-toggle')

    // Initially password should be hidden
    expect(passwordInput).toHaveAttribute('type', 'password')

    // Click toggle button
    fireEvent.click(toggleButton)

    // Password should be visible
    expect(passwordInput).toHaveAttribute('type', 'text')

    // Click toggle button again
    fireEvent.click(toggleButton)

    // Password should be hidden again
    expect(passwordInput).toHaveAttribute('type', 'password')
  })

  it('should navigate to forgot password page when link is clicked', () => {
    const mockPush = jest.fn()
    require('next/router').useRouter.mockReturnValue({
      push: mockPush,
    })

    render(<LoginForm />)

    const forgotPasswordLink = screen.getByText('Forgot Password?')
    fireEvent.click(forgotPasswordLink)

    expect(mockPush).toHaveBeenCalledWith('/forgot-password')
  })

  it('should navigate to register page when link is clicked', () => {
    const mockPush = jest.fn()
    require('next/router').useRouter.mockReturnValue({
      push: mockPush,
    })

    render(<LoginForm />)

    const registerLink = screen.getByText('Create Account')
    fireEvent.click(registerLink)

    expect(mockPush).toHaveBeenCalledWith('/register')
  })
})
