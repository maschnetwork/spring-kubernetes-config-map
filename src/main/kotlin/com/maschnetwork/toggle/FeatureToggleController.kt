package com.maschnetwork.toggle

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class FeatureToggleController(private val featureToggleConfiguration: FeatureToggleConfiguration) {

    @GetMapping("/toggles/limit")
    fun getToggle(): Int {
        return featureToggleConfiguration.limit
    }

    @GetMapping("/toggles/hello")
    fun getHello(): String {
        return featureToggleConfiguration.test
    }


}