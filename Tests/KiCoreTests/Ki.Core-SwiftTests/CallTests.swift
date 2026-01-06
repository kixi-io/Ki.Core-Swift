//
//  CallTests.swift
//  Ki.Core-Swift
//
//  Copyright © 2026 Kixi. MIT License.
//

import Testing
import Foundation
@testable import KiCore

/// Comprehensive tests for the Call class.
@Suite("Call Tests")
struct CallTests {
    
    // MARK: - Initialization Tests
    
    @Suite("Initialization")
    struct InitializationTests {
        
        @Test("Create Call with NSID")
        func createWithNSID() throws {
            let nsid = try NSID("example")
            let call = Call(nsid)
            
            #expect(call.nsid == nsid)
            #expect(call.name == "example")
            #expect(call.namespace == "")
            #expect(!call.hasValues())
            #expect(!call.hasAttributes())
        }
        
        @Test("Create Call with namespaced NSID")
        func createWithNamespacedNSID() throws {
            let nsid = try NSID("tag", namespace: "my")
            let call = Call(nsid)
            
            #expect(call.nsid == nsid)
            #expect(call.name == "tag")
            #expect(call.namespace == "my")
        }
        
        @Test("Create Call with name string")
        func createWithName() throws {
            let call = Call("myFunction")
            
            #expect(call.name == "myFunction")
            #expect(call.namespace == "")
        }
        
        @Test("Create Call with name and namespace")
        func createWithNameAndNamespace() throws {
            let call = try Call("process", namespace: "api")
            
            #expect(call.name == "process")
            #expect(call.namespace == "api")
        }
        
        @Test("Create Call with NSID and values")
        func createWithNSIDAndValues() throws {
            let nsid = try NSID("add")
            let values: [Any?] = [1, 2, 3]
            let call = Call(nsid, values: values)
            
            #expect(call.name == "add")
            #expect(call.hasValues())
            #expect(call.valueCount == 3)
            #expect(call.values[0] as? Int == 1)
            #expect(call.values[1] as? Int == 2)
            #expect(call.values[2] as? Int == 3)
        }
        
        @Test("Create Call with name and values")
        func createWithNameAndValues() throws {
            let values: [Any?] = [10, 20]
            let call = try Call("sum", values: values)
            
            #expect(call.name == "sum")
            #expect(call.hasValues())
            #expect(call.valueCount == 2)
        }
        
        @Test("Create Call with empty values array does not initialize values")
        func createWithEmptyValues() throws {
            let emptyValues: [Any?] = []
            let call = try Call("empty", values: emptyValues)
            
            #expect(!call.hasValues())
            #expect(call.valueCount == 0)
        }
        
        @Test("Create Call with NSID and attributes")
        func createWithNSIDAndAttributes() throws {
            let nsid = try NSID("config")
            let debugAttr = try NSID("debug")
            let attrs: [NSID: Any?] = [debugAttr: true]
            let call = Call(nsid, attributes: attrs)
            
            #expect(call.name == "config")
            #expect(call.hasAttributes())
            #expect(call.attributeCount == 1)
        }
        
        @Test("Create Call with name and attributes")
        func createWithNameAndAttributes() throws {
            let levelAttr = try NSID("level")
            let attrs: [NSID: Any?] = [levelAttr: 5]
            let call = try Call("settings", attributes: attrs)
            
            #expect(call.name == "settings")
            #expect(call.hasAttributes())
            #expect(call.attributeCount == 1)
        }
        
        @Test("Create Call with empty attributes does not initialize attributes")
        func createWithEmptyAttributes() throws {
            let emptyAttrs: [NSID: Any?] = [:]
            let call = try Call("noAttrs", attributes: emptyAttrs)
            
            #expect(!call.hasAttributes())
            #expect(call.attributeCount == 0)
        }
        
        @Test("Create Call with NSID, values, and attributes")
        func createWithNSIDValuesAndAttributes() throws {
            let nsid = try NSID("request")
            let timeoutAttr = try NSID("timeout")
            let getStr: String = "GET"
            let apiStr: String = "/api"
            let values: [Any?] = [getStr, apiStr]
            let attrs: [NSID: Any?] = [timeoutAttr: 30]
            let call: Call = Call(nsid, values: values, attributes: attrs)
            
            #expect(call.name == "request")
            #expect(call.hasValues())
            #expect(call.hasAttributes())
            #expect(call.valueCount == 2)
            #expect(call.attributeCount == 1)
        }
        
        @Test("Create Call with name, values, and attributes")
        func createWithNameValuesAndAttributes() throws {
            let urgentAttr = try NSID("urgent")
            let itemStr: String = "item"
            let values: [Any?] = [itemStr, 5]
            let attrs: [NSID: Any?] = [urgentAttr: true]
            let call = try Call("create",
                               values: values,
                               attributes: attrs)
            
            #expect(call.name == "create")
            #expect(call.valueCount == 2)
            #expect(call.attributeCount == 1)
        }
        
        @Test("Create Call with namespace, values, and attributes")
        func createWithNamespaceValuesAndAttributes() throws {
            let idAttr = try NSID("id")
            let v1: String = "/users"
            let values: [Any?] = [v1]
            let attrs: [NSID: Any?] = [idAttr: 123]
            let call = try Call("fetch",
                               namespace: "api",
                               values: values,
                               attributes: attrs)
            
            #expect(call.name == "fetch")
            #expect(call.namespace == "api")
            #expect(call.valueCount == 1)
            #expect(call.attributeCount == 1)
        }
        
        @Test("Invalid name throws ParseError")
        func invalidNameThrows() throws {
            #expect(throws: (any Error).self) {
                // try Call("123invalid")
                let invalidName: String = "123invalid"
                try Call(invalidName)
            }
        }
        
        @Test("Invalid namespace throws ParseError")
        func invalidNamespaceThrows() throws {
            #expect(throws: (any Error).self) {
                try Call("valid", namespace: "123invalid")
            }
        }
    }
    
    // MARK: - ExpressibleByStringLiteral Tests
    
    @Suite("ExpressibleByStringLiteral")
    struct StringLiteralTests {
        
        @Test("Create Call from string literal")
        func createFromStringLiteral() {
            let call: Call = "myCall"
            
            #expect(call.name == "myCall")
            #expect(call.namespace == "")
        }
        
        @Test("String literal Call has no values or attributes")
        func stringLiteralHasNoValuesOrAttributes() {
            let call: Call = "simple"
            
            #expect(!call.hasValues())
            #expect(!call.hasAttributes())
        }
    }
    
    // MARK: - Lazy Initialization Tests
    
    @Suite("Lazy Initialization")
    struct LazyInitializationTests {
        
        @Test("Values not initialized until accessed")
        func valuesLazyInit() throws {
            let call = Call("test")
            
            // hasValues() should not trigger initialization
            #expect(!call.hasValues())
            #expect(call.valueCount == 0)
            
            // Accessing values triggers initialization
            let _ = call.values
            #expect(call.values.isEmpty)
        }
        
        @Test("Attributes not initialized until accessed")
        func attributesLazyInit() throws {
            let call = Call("test")
            
            // hasAttributes() should not trigger initialization
            #expect(!call.hasAttributes())
            #expect(call.attributeCount == 0)
            
            // Accessing attributes triggers initialization
            let _ = call.attributes
            #expect(call.attributes.isEmpty)
        }
    }
    
    // MARK: - Value Access Tests
    
    @Suite("Value Access")
    struct ValueAccessTests {
        
        @Test("Value property returns first value")
        func valuePropertyReturnsFirst() throws {
            let v1: String = "first"
            let v2: String = "second"
            let values: [Any?] = [v1, v2]
            let call = try Call("test", values: values)
            
            #expect(call.value as? String == "first")
        }
        
        @Test("Value property returns nil when empty")
        func valuePropertyReturnsNilWhenEmpty() throws {
            let call = Call("test")
            
            #expect(call.value == nil)
        }
        
        @Test("Setting value property when empty appends")
        func settingValueWhenEmptyAppends() throws {
            let call = Call("test")
            let newValueStr: String = "newValue"
            call.value = newValueStr
            
            #expect(call.valueCount == 1)
            #expect(call.value as? String == "newValue")
        }
        
        @Test("Setting value property when not empty replaces first")
        func settingValueReplacesFirst() throws {
            let v1: String = "original"
            let v2: String = "second"
            let values: [Any?] = [v1, v2]
            let call = try Call("test", values: values)
            let replacedStr: String = "replaced"
            call.value = replacedStr
            
            #expect(call.valueCount == 2)
            #expect(call.value as? String == "replaced")
            #expect(call.values[1] as? String == "second")
        }
        
        @Test("hasValue(at:) returns correct values")
        func hasValueAt() throws {
            let values: [Any?] = [1, 2, 3]
            let call = try Call("test", values: values)
            
            #expect(call.hasValue(at: 0))
            #expect(call.hasValue(at: 1))
            #expect(call.hasValue(at: 2))
            #expect(!call.hasValue(at: 3))
            #expect(!call.hasValue(at: -1))
        }
        
        @Test("getValue(at:default:) returns value when present")
        func getValueWithDefaultReturnsValue() throws {
            let values: [Any?] = [42]
            let call = try Call("test", values: values)
            
            let result: Int = call.getValue(at: 0, default: 0)
            #expect(result == 42)
        }
        
        @Test("getValue(at:default:) returns default when missing")
        func getValueWithDefaultReturnsDefault() throws {
            let emptyValues: [Any?] = []
            let call = try Call("test", values: emptyValues)
            
            let result: Int = call.getValue(at: 0, default: 99)
            #expect(result == 99)
        }
        
        @Test("getValue(at:default:) returns default for wrong type")
        func getValueWithDefaultReturnsDefaultForWrongType() throws {
            let notAnInt: String = "not an int"
            let values: [Any?] = [notAnInt]
            let call = try Call("test", values: values)
            
            let result: Int = call.getValue(at: 0, default: 99)
            #expect(result == 99)
        }
        
        @Test("getValue(at:) returns value when present")
        func getValueOptionalReturnsValue() throws {
            let helloStr: String = "hello"
            let values: [Any?] = [helloStr]
            let call = try Call("test", values: values)
            
            let result: String? = call.getValue(at: 0)
            #expect(result == "hello")
        }
        
        @Test("getValue(at:) returns nil when missing")
        func getValueOptionalReturnsNilWhenMissing() throws {
            let call = Call("test")
            
            let result: String? = call.getValue(at: 0)
            #expect(result == nil)
        }
        
        @Test("Subscript access to values by index")
        func subscriptByIndex() throws {
            let values: [Any?] = [1, 2, 3]
            let call = try Call("test", values: values)
            
            #expect(call[0] as? Int == 1)
            #expect(call[1] as? Int == 2)
            #expect(call[2] as? Int == 3)
        }
        
        @Test("Subscript setter modifies values")
        func subscriptSetterModifiesValues() throws {
            let values: [Any?] = [1, 2, 3]
            let call = try Call("test", values: values)
            call[1] = 20
            
            #expect(call[1] as? Int == 20)
        }
        
        @Test("Values can contain nil")
        func valuesCanContainNil() throws {
            let values: [Any?] = [1, nil, 3]
            let call = try Call("test", values: values)
            
            #expect(call.valueCount == 3)
            #expect(call[0] as? Int == 1)
            #expect(call[1] == nil)
            #expect(call[2] as? Int == 3)
        }
        
        @Test("Values can contain mixed types")
        func valuesCanContainMixedTypes() throws {
            let twoStr: String = "two"
            let values: [Any?] = [1, twoStr, 3.0, true]
            let call = try Call("test", values: values)
            
            #expect(call.valueCount == 4)
            #expect(call[0] as? Int == 1)
            #expect(call[1] as? String == "two")
            #expect(call[2] as? Double == 3.0)
            #expect(call[3] as? Bool == true)
        }
    }
    
    // MARK: - Attribute Access Tests
    
    @Suite("Attribute Access")
    struct AttributeAccessTests {
        
        @Test("hasAttribute with NSID returns correct value")
        func hasAttributeWithNSID() throws {
            let debugAttr = try NSID("debug")
            let attrs: [NSID: Any?] = [debugAttr: true]
            let call = try Call("test", attributes: attrs)
            
            #expect(call.hasAttribute(debugAttr))
            #expect(!call.hasAttribute(try NSID("missing")))
        }
        
        @Test("hasAttribute with name returns correct value")
        func hasAttributeWithName() throws {
            let debugAttr = try NSID("debug")
            let attrs: [NSID: Any?] = [debugAttr: true]
            let call = try Call("test", attributes: attrs)
            
            #expect(try call.hasAttribute("debug"))
            #expect(try !call.hasAttribute("missing"))
        }
        
        @Test("hasAttribute with name and namespace")
        func hasAttributeWithNameAndNamespace() throws {
            let nsAttr = try NSID("setting", namespace: "config")
            let valueStr: String = "value"
            let attrs: [NSID: Any?] = [nsAttr: valueStr]
            let call = try Call("test", attributes: attrs)
            
            #expect(try call.hasAttribute("setting", namespace: "config"))
            #expect(try !call.hasAttribute("setting", namespace: ""))
            #expect(try !call.hasAttribute("setting", namespace: "other"))
        }
        
        @Test("setAttribute with NSID sets and returns old value")
        func setAttributeWithNSID() throws {
            let call = Call("test")
            let attr = try NSID("key")
            
            let firstStr: String = "first"
            let old1 = call.setAttribute(attr, value: firstStr)
            #expect(old1 == nil)
            
            let secondStr: String = "second"
            let old2 = call.setAttribute(attr, value: secondStr)
            #expect(old2 as? String == "first")
        }
        
        @Test("setAttribute with name sets value")
        func setAttributeWithName() throws {
            let call = Call("test")
            
            let valueStr: String = "value"
            try call.setAttribute("key", value: valueStr)
            
            #expect(try call.hasAttribute("key"))
        }
        
        @Test("setAttribute with name and namespace")
        func setAttributeWithNameAndNamespace() throws {
            let call = Call("test")
            
            try call.setAttribute("setting", namespace: "config", value: 42)
            
            #expect(try call.hasAttribute("setting", namespace: "config"))
        }
        
        @Test("getAttribute with NSID returns value")
        func getAttributeWithNSID() throws {
            let attr = try NSID("count")
            let attrs: [NSID: Any?] = [attr: 42]
            let call = try Call("test", attributes: attrs)
            
            let result: Int? = call.getAttribute(attr)
            #expect(result == 42)
        }
        
        @Test("getAttribute with NSID returns nil when missing")
        func getAttributeWithNSIDReturnsNilWhenMissing() throws {
            let call = Call("test")
            
            let result: Int? = call.getAttribute(try NSID("missing"))
            #expect(result == nil)
        }
        
        @Test("getAttribute with name returns value")
        func getAttributeWithName() throws {
            let attr = try NSID("name")
            let johnStr: String = "John"
            let attrs: [NSID: Any?] = [attr: johnStr]
            let call = try Call("test", attributes: attrs)
            
            let result: String? = try call.getAttribute("name")
            #expect(result == "John")
        }
        
        @Test("getAttribute with default returns value when present")
        func getAttributeWithDefaultReturnsValue() throws {
            let attr = try NSID("level")
            let attrs: [NSID: Any?] = [attr: 5]
            let call = try Call("test", attributes: attrs)
            
            let result: Int = call.getAttribute(attr, default: 1)
            #expect(result == 5)
        }
        
        @Test("getAttribute with default returns default when missing")
        func getAttributeWithDefaultReturnsDefaultWhenMissing() throws {
            let call = Call("test")
            
            let result: Int = call.getAttribute(try NSID("level"), default: 1)
            #expect(result == 1)
        }
        
        @Test("getAttribute with name and default")
        func getAttributeWithNameAndDefault() throws {
            let call = Call("test")
            
            let result: String = try call.getAttribute("name", default: "default")
            #expect(result == "default")
        }
        
        @Test("getAttributes(inNamespace:) filters by namespace")
        func getAttributesInNamespace() throws {
            let attr1 = try NSID("setting1", namespace: "config")
            let attr2 = try NSID("setting2", namespace: "config")
            let attr3 = try NSID("other", namespace: "other")
            let attr4 = try NSID("noNamespace")
            
            let v1: String = "value1"
            let v2: String = "value2"
            let v3: String = "value3"
            let v4: String = "value4"
            let attrs: [NSID: Any?] = [
                attr1: v1,
                attr2: v2,
                attr3: v3,
                attr4: v4
            ]
            let call = try Call("test", attributes: attrs)
            
            let configAttrs: [String: String] = call.getAttributes(inNamespace: "config")
            
            #expect(configAttrs.count == 2)
            #expect(configAttrs["setting1"] == "value1")
            #expect(configAttrs["setting2"] == "value2")
        }
        
        @Test("getAttributes(inNamespace:) returns empty for no matches")
        func getAttributesInNamespaceReturnsEmptyForNoMatches() throws {
            let attr = try NSID("key")
            let valueStr: String = "value"
            let attrs: [NSID: Any?] = [attr: valueStr]
            let call = try Call("test", attributes: attrs)
            
            let result: [String: String] = call.getAttributes(inNamespace: "nonexistent")
            #expect(result.isEmpty)
        }
        
        @Test("Subscript access by NSID")
        func subscriptByNSID() throws {
            let attr = try NSID("key")
            let valueStr: String = "value"
            let attrs: [NSID: Any?] = [attr: valueStr]
            let call = try Call("test", attributes: attrs)
            
            #expect(call[attr] as? String == "value")
        }
        
        @Test("Subscript setter by NSID")
        func subscriptSetterByNSID() throws {
            let attr = try NSID("key")
            let call = Call("test")
            
            let newValueStr: String = "newValue"
            call[attr] = newValueStr
            
            #expect(call[attr] as? String == "newValue")
        }
        
        @Test("Subscript access by name")
        func subscriptByName() throws {
            let attr = try NSID("key")
            let attrs: [NSID: Any?] = [attr: 42]
            let call = try Call("test", attributes: attrs)
            
            #expect(call["key"] as? Int == 42)
        }
        
        @Test("Subscript setter by name")
        func subscriptSetterByName() throws {
            let call = Call("test")
            
            let valueStr: String = "value"
            call["key"] = valueStr
            
            #expect(call["key"] as? String == "value")
        }
        
        @Test("Subscript access by name and namespace")
        func subscriptByNameAndNamespace() throws {
            let attr = try NSID("setting", namespace: "config")
            let attrs: [NSID: Any?] = [attr: true]
            let call = try Call("test", attributes: attrs)
            
            #expect(call["setting", "config"] as? Bool == true)
        }
        
        @Test("Subscript setter by name and namespace")
        func subscriptSetterByNameAndNamespace() throws {
            let call = Call("test")
            
            call["setting", "config"] = 100
            
            #expect(call["setting", "config"] as? Int == 100)
        }
        
        @Test("Attributes can contain nil values")
        func attributesCanContainNil() throws {
            let attr = try NSID("nullable")
            let attrs: [NSID: Any?] = [attr: nil]
            let call = try Call("test", attributes: attrs)
            
            #expect(call.hasAttribute(attr))
            #expect(call[attr] == nil)
        }
    }
    
    // MARK: - Fluent Builder Tests
    
    @Suite("Fluent Builders")
    struct FluentBuilderTests {
        
        @Test("withValue adds value and returns self")
        func withValueAddsValue() throws {
            let call = Call("test")
            let result = call.withValue(42)
            
            #expect(result === call)
            #expect(call.valueCount == 1)
            #expect(call[0] as? Int == 42)
        }
        
        @Test("withValue chaining")
        func withValueChaining() throws {
            let call = Call("test")
                .withValue(1)
                .withValue(2)
                .withValue(3)
            
            #expect(call.valueCount == 3)
            #expect(call[0] as? Int == 1)
            #expect(call[1] as? Int == 2)
            #expect(call[2] as? Int == 3)
        }
        
        @Test("withValues adds multiple values")
        func withValuesAddsMultiple() throws {
            let aStr: String = "a"
            let bStr: String = "b"
            let cStr: String = "c"
            let call = Call("test")
                .withValues(aStr, bStr, cStr)
            
            #expect(call.valueCount == 3)
            #expect(call[0] as? String == "a")
            #expect(call[1] as? String == "b")
            #expect(call[2] as? String == "c")
        }
        
        @Test("withAttribute with name adds attribute")
        func withAttributeAddsAttribute() throws {
            let valueStr: String = "value"
            let call = Call("test")
                .withAttribute("key", value: valueStr)
            
            #expect(call.attributeCount == 1)
            #expect(call["key"] as? String == "value")
        }
        
        @Test("withAttribute with name and namespace")
        func withAttributeWithNamespace() throws {
            let call = Call("test")
                .withAttribute("setting", namespace: "config", value: true)
            
            #expect(call["setting", "config"] as? Bool == true)
        }
        
        @Test("withAttribute with NSID")
        func withAttributeWithNSID() throws {
            let attr = try NSID("key")
            let call = Call("test")
                .withAttribute(attr, value: 42)
            
            #expect(call[attr] as? Int == 42)
        }
        
        @Test("Complex fluent chaining")
        func complexFluentChaining() throws {
            let getStr: String = "GET"
            let apiUsersStr: String = "/api/users"
            let timeoutAttr = try NSID("timeout")
            let retryAttr = try NSID("retry")
            let call = Call("request")
                .withValue(getStr)
                .withValue(apiUsersStr)
                .withAttribute(timeoutAttr, value: 30)
                .withAttribute(retryAttr, value: true)
            
            #expect(call.name == "request")
            #expect(call.valueCount == 2)
            #expect(call.attributeCount == 2)
            #expect(call[0] as? String == "GET")
            #expect(call[1] as? String == "/api/users")
            #expect(call["timeout"] as? Int == 30)
            #expect(call["retry"] as? Bool == true)
        }
    }
    
    // MARK: - Description Tests
    
    @Suite("CustomStringConvertible")
    struct DescriptionTests {
        
        @Test("Description for empty Call")
        func descriptionForEmptyCall() throws {
            let call = Call("example")
            
            #expect(call.description == "example()")
        }
        
        @Test("Description for namespaced Call")
        func descriptionForNamespacedCall() throws {
            let call = try Call("action", namespace: "ns")
            
            #expect(call.description == "ns:action()")
        }
        
        @Test("Description with values")
        func descriptionWithValues() throws {
            let values: [Any?] = [1, 2, 3]
            let call = try Call("add", values: values)
            
            #expect(call.description == "add(1, 2, 3)")
        }
        
        @Test("Description with string values shows quotes")
        func descriptionWithStringValues() throws {
            let helloStr: String = "hello"
            let worldStr: String = "world"
            let values: [Any?] = [helloStr, worldStr]
            let call = try Call("greet", values: values)
            
            #expect(call.description == "greet(\"hello\", \"world\")")
        }
        
        @Test("Description with nil value")
        func descriptionWithNilValue() throws {
            let values: [Any?] = [1, nil, 3]
            let call = try Call("test", values: values)
            
            #expect(call.description == "test(1, nil, 3)")
        }
        
        @Test("Description with boolean values")
        func descriptionWithBooleanValues() throws {
            let values: [Any?] = [true, false]
            let call = try Call("flags", values: values)
            
            #expect(call.description == "flags(true, false)")
        }
        
        @Test("Description with attributes")
        func descriptionWithAttributes() throws {
            let debugAttr = try NSID("debug")
            let attrs: [NSID: Any?] = [debugAttr: true]
            let call = try Call("config", attributes: attrs)
            
            // Note: attribute order in dictionary may vary
            let configStr: String = "config("
            let debugStr: String = "debug=true"
            let containsConfig: Bool = call.description.contains(configStr)
            #expect(containsConfig)
            let containsDebug: Bool = call.description.contains(debugStr)
            #expect(containsDebug)
        }
        
        @Test("Description with namespaced attribute")
        func descriptionWithNamespacedAttribute() throws {
            let attr = try NSID("setting", namespace: "cfg")
            let attrs: [NSID: Any?] = [attr: 5]
            let call = try Call("test", attributes: attrs)
            
            let namespacedStr: String = "cfg:setting=5"
            let containsNamespaced: Bool = call.description.contains(namespacedStr)
            #expect(containsNamespaced)
        }
        
        @Test("Description with values and attributes")
        func descriptionWithValuesAndAttributes() throws {
            let urgentAttr = try NSID("urgent")
            let itemStr: String = "item"
            let values: [Any?] = [itemStr]
            let attrs: [NSID: Any?] = [urgentAttr: true]
            let call = try Call("create", values: values, attributes: attrs)
            
            // Values come before attributes
            let createStr: String = "create("
            let quotedItemStr: String = "\"item\""
            let urgentStr: String = "urgent=true"
            let containsCreate: Bool = call.description.contains(createStr)
            #expect(containsCreate)
            let containsItem: Bool = call.description.contains(quotedItemStr)
            #expect(containsItem)
            let containsUrgent: Bool = call.description.contains(urgentStr)
            #expect(containsUrgent)
        }
    }
    
    // MARK: - Equality and Hashing Tests
    
    @Suite("Equality and Hashing")
    struct EqualityHashingTests {
        
        @Test("Equal Calls are equal")
        func equalCallsAreEqual() throws {
            let values: [Any?] = [1, 2, 3]
            let call1 = try Call("test", values: values)
            let call2 = try Call("test", values: values)
            
            #expect(call1 == call2)
        }
        
        @Test("Different names are not equal")
        func differentNamesNotEqual() throws {
            let call1 = Call("test1")
            let call2 = Call("test2")
            
            #expect(call1 != call2)
        }
        
        @Test("Different values are not equal")
        func differentValuesNotEqual() throws {
            let values1: [Any?] = [1, 2]
            let values2: [Any?] = [1, 3]
            let call1 = try Call("test", values: values1)
            let call2 = try Call("test", values: values2)
            
            #expect(call1 != call2)
        }
        
        @Test("Different attributes are not equal")
        func differentAttributesNotEqual() throws {
            let attr = try NSID("key")
            let attrs1: [NSID: Any?] = [attr: 1]
            let attrs2: [NSID: Any?] = [attr: 2]
            let call1 = try Call("test", attributes: attrs1)
            let call2 = try Call("test", attributes: attrs2)
            
            #expect(call1 != call2)
        }
        
        @Test("Equal Calls have equal hash values")
        func equalCallsHaveEqualHashes() throws {
            let values: [Any?] = [1, 2]
            let call1 = try Call("test", values: values)
            let call2 = try Call("test", values: values)
            
            #expect(call1.hashValue == call2.hashValue)
        }
        
        @Test("Calls work in Set")
        func callsWorkInSet() throws {
            let values1: [Any?] = [1]
            let values2: [Any?] = [2]
            let call1 = try Call("test", values: values1)
            let call2 = try Call("test", values: values2)
            let call3 = try Call("test", values: values1)  // Duplicate of call1
            
            let set: Set<Call> = [call1, call2, call3]
            
            #expect(set.count == 2)
        }
        
        @Test("Calls work as Dictionary keys")
        func callsWorkAsDictionaryKeys() throws {
            let call1 = Call("key1")
            let call2 = Call("key2")
            
            var dict: [Call: String] = [:]
            dict[call1] = "value1"
            dict[call2] = "value2"
            
            #expect(dict[call1] == "value1")
            #expect(dict[call2] == "value2")
        }
    }
    
    // MARK: - Parseable Conformance Tests
    
    @Suite("Parseable Conformance")
    struct ParseableTests {
        
        @Test("parseLiteral always throws in KiCore")
        func parseLiteralThrows() {
            #expect(throws: (any Error).self) {
                try Call.parseLiteral("test(1, 2, 3)")
            }
        }
        
        @Test("parseOrNull always returns nil in KiCore")
        func parseOrNullReturnsNil() {
            let result = Call.parseOrNull("test(1, 2, 3)")
            #expect(result == nil)
        }
    }
    
    // MARK: - Edge Cases and Special Values
    
    @Suite("Edge Cases")
    struct EdgeCaseTests {
        
        @Test("Values array can be set directly")
        func valuesCanBeSetDirectly() throws {
            let call = Call("test")
            let newValues: [Any?] = [1, 2, 3]
            call.values = newValues
            
            #expect(call.valueCount == 3)
        }
        
        @Test("Attributes dictionary can be set directly")
        func attributesCanBeSetDirectly() throws {
            let attr = try NSID("key")
            let call = Call("test")
            let valueStr: String = "value"
            let newAttrs: [NSID: Any?] = [attr: valueStr]
            call.attributes = newAttrs
            
            #expect(call.attributeCount == 1)
        }
        
        @Test("NSID property can be changed")
        func nsidCanBeChanged() throws {
            let call = Call("original")
            call.nsid = try NSID("modified", namespace: "ns")
            
            #expect(call.name == "modified")
            #expect(call.namespace == "ns")
        }
        
        @Test("Values support URL type")
        func valuesSupportURL() throws {
            let url = URL(string: "https://example.com")!
            let values: [Any?] = [url]
            let call = try Call("fetch", values: values)
            
            #expect(call[0] as? URL == url)
        }
        
        @Test("Values support Decimal type")
        func valuesSupportDecimal() throws {
            let decimal = Decimal(string: "123.456")!
            let values: [Any?] = [decimal]
            let call = try Call("calc", values: values)
            
            #expect(call[0] as? Decimal == decimal)
        }
        
        @Test("Values support arrays")
        func valuesSupportArrays() throws {
            let innerArray: [Any?] = [1, 2, 3]
            let values: [Any?] = [innerArray]
            let call = try Call("test", values: values)
            
            #expect(call.valueCount == 1)
            if let inner = call[0] as? [Any?] {
                #expect(inner.count == 3)
            } else {
                Issue.record("Expected array value")
            }
        }
        
        @Test("Attributes with same name different namespace are distinct")
        func attributesSameNameDifferentNamespace() throws {
            let attr1 = try NSID("key", namespace: "ns1")
            let attr2 = try NSID("key", namespace: "ns2")
            let v1: String = "value1"
            let v2: String = "value2"
            let attrs: [NSID: Any?] = [
                attr1: v1,
                attr2: v2
            ]
            let call = try Call("test", attributes: attrs)
            
            #expect(call.attributeCount == 2)
            #expect(call["key", "ns1"] as? String == "value1")
            #expect(call["key", "ns2"] as? String == "value2")
        }
        
        @Test("Empty Call description")
        func emptyCallDescription() throws {
            let call = Call("empty")
            
            #expect(call.description == "empty()")
            #expect(!call.hasValues())
            #expect(!call.hasAttributes())
        }
        
        @Test("Multiple operations on same Call")
        func multipleOperationsOnSameCall() throws {
            let call = Call("test")
            
            // Add values
            call.withValue(1)
            call.withValue(2)
            
            // Add attributes
            let xStr: String = "x"
            let yStr: String = "y"
            call.withAttribute("a", value: xStr)
            call.withAttribute("b", value: yStr)
            
            // Modify via subscripts
            call[0] = 10
            let modifiedStr: String = "modified"
            call["a"] = modifiedStr
            
            #expect(call[0] as? Int == 10)
            #expect(call[1] as? Int == 2)
            #expect(call["a"] as? String == "modified")
            #expect(call["b"] as? String == "y")
        }
    }
    
    // MARK: - Subclassing Tests
    
    @Suite("Subclassing")
    struct SubclassingTests {
        
        // Custom subclass for testing
        final class TestTag: Call {
            var annotation: String?

            // Designated initializer that calls a designated initializer of Call
            init(name: String, annotation: String? = nil) throws {
                let nsid = try NSID(name)
                super.init(nsid)
                self.annotation = annotation
            }

            // Required initializer from ExpressibleByStringLiteral conformance
            required convenience init(stringLiteral value: String) {
                do {
                    try self.init(name: value)
                } catch {
                    fatalError("Invalid literal: \(value)")
                }
            }
        }
        
        @Test("Call can be subclassed")
        func callCanBeSubclassed() throws {
            let tag = try TestTag(name: "myTag", annotation: "note")
            
            #expect(tag.name == "myTag")
            #expect(tag.annotation == "note")
        }
        
        @Test("Subclass inherits fluent builders")
        func subclassInheritsFluentBuilders() throws {
            let valueStr: String = "value"
            let tag = try TestTag(name: "myTag")
                .withValue(1)
                .withAttribute("key", value: valueStr)
            
            #expect(tag.valueCount == 1)
            #expect(tag.attributeCount == 1)
        }
        
        @Test("Subclass fluent builders return Self")
        func subclassFluentBuildersReturnSelf() throws {
            let tag = try TestTag(name: "myTag", annotation: "note")
            let result = tag.withValue(1)
            
            // Should return the same TestTag instance
            #expect(result === tag)
            #expect((result as? TestTag)?.annotation == "note")
        }
    }
    
    // MARK: - Thread Safety Considerations
    
    @Suite("Reference Semantics")
    struct ReferenceSemanticsTests {
        
        @Test("Call is a reference type (class)")
        func callIsReferenceType() throws {
            let call1 = Call("test")
            let call2 = call1
            
            call1.withValue(1)
            
            #expect(call2.valueCount == 1)
            #expect(call1 === call2)
        }
    }
}
