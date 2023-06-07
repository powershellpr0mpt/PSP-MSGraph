Describe 'Invoke-MSGraphMethod' {

    $Token = [PSP_MSGraph_Token]::new()
    $Token.TokenType = 'Bearer'
    $Token.TokenContent = 'abc123'
    $Token.TokenExpiration = 5221
    $Uri = 'https://graph.microsoft.com/v1.0/me'
    $Method = 'Get'

    Context 'when given valid parameters' {
        It 'should return data from the Microsoft Graph API' {
            # Create a mock HTTP client to simulate the response from the API
            Mock Invoke-RestMethod { return @{ value = 'Mock data' } } -Verifiable -ParameterFilter { $Uri -eq 'https://graph.microsoft.com/v1.0/me' }

            $Results = Invoke-MSGraphMethod -Token $Token -Uri $Uri -Method $Method
            $Results | Should Not BeNullOrEmpty

            # Verify that the mock HTTP client was called with the correct parameters
            Assert-VerifiableMocks
        }
    }

    Context 'when given an invalid URI' {
        It 'should throw an error' {
            # Create a mock HTTP client to simulate the response from the API
            Mock Invoke-RestMethod { throw 'Invalid URI' } -Verifiable -ParameterFilter { $Uri -eq 'https://graph.microsoft.com/v1.0/invalid' }

            $Uri = 'https://graph.microsoft.com/v1.0/invalid'
            { Invoke-MSGraphMethod -Token $Token -Uri $Uri -Method $Method } | Should Throw

            # Verify that the mock HTTP client was called with the correct parameters
            Assert-VerifiableMocks
        }
    }

    Context 'when given an invalid method' {
        It 'should throw an error' {
            # Create a mock HTTP client to simulate the response from the API
            Mock Invoke-RestMethod { throw 'Invalid method' } -Verifiable -ParameterFilter { $Uri -eq 'https://graph.microsoft.com/v1.0/me' }

            $Method = 'InvalidMethod'
            { Invoke-MSGraphMethod -Token $Token -Uri $Uri -Method $Method } | Should Throw

            # Verify that the mock HTTP client was called with the correct parameters
            Assert-VerifiableMocks
        }
    }
}