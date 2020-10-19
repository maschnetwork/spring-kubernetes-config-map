package com.maschnetwork.toggle

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.context.annotation.Configuration

@Configuration
@ConfigurationProperties(prefix = "feature-toggle")
class FeatureToggleConfiguration {

    var something: Boolean = false
    var limit: Int = 1000
    var camelCase: Boolean = false
    var test: String = "Hallo Static"

}