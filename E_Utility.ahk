﻿/*
 * Copyright (C) 2023 NeonOrbit
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

NULL := 0

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
        super.set(item, NULL)
    }

    get(item) {
        ThrowUnsupported
    }

    __item[item] {
        get { 
            ThrowUnsupported
        }
        set { 
            ThrowUnsupported
        }
    }
}

ThrowUnsupported() {
    throw Error("Unsupported Operation")
}
