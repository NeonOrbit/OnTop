
BypassThisRef(callback, _this, param*) {
    callback(param*)
}

class ExMap extends Map {
    __new(def := "") {
        super.__new()
        super.default := def
    }
}

class ExSet extends Map {
    add(item) {
        super.set(item, "")
    }

    get(item) {
        throw Error("Unsupported Operation")
    }

    __item[item] {
        get { 
            throw Error("Unsupported Operation")
        }
        set { 
            throw Error("Unsupported Operation")
        }
    }
}
