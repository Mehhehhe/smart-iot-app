// pub use std::collections::HashMap;

pub use serde::Deserialize;
pub use serde::Serialize;
// pub use serde_json::Value;

// This is the entry point of your Rust library.
// When adding new code to your project, note that only items used
// here will be transformed to their Dart equivalents.

// A plain enum without any fields. This is similar to Dart- or C-style enums.
// flutter_rust_bridge is capable of generating code for enums with fields
// (@freezed classes in Dart and tagged unions in C).
pub enum Platform {
    Unknown,
    Android,
    Ios,
    Windows,
    Unix,
    MacIntel,
    MacApple,
    Wasm,
}

// A function definition in Rust. Similar to Dart, the return type must always be named
// and is never inferred.
pub fn platform() -> Platform {
    // This is a macro, a special expression that expands into code. In Rust, all macros
    // end with an exclamation mark and can be invoked with all kinds of brackets (parentheses,
    // brackets and curly braces). However, certain conventions exist, for example the
    // vector macro is almost always invoked as vec![..].
    //
    // The cfg!() macro returns a boolean value based on the current compiler configuration.
    // When attached to expressions (#[cfg(..)] form), they show or hide the expression at compile time.
    // Here, however, they evaluate to runtime values, which may or may not be optimized out
    // by the compiler. A variety of configurations are demonstrated here which cover most of
    // the modern oeprating systems. Try running the Flutter application on different machines
    // and see if it matches your expected OS.
    //
    // Furthermore, in Rust, the last expression in a function is the return value and does
    // not have the trailing semicolon. This entire if-else chain forms a single expression.
    if cfg!(windows) {
        Platform::Windows
    } else if cfg!(target_os = "android") {
        Platform::Android
    } else if cfg!(target_os = "ios") {
        Platform::Ios
    } else if cfg!(all(target_os = "macos", target_arch = "aarch64")) {
        Platform::MacApple
    } else if cfg!(target_os = "macos") {
        Platform::MacIntel
    } else if cfg!(target_family = "wasm") {
        Platform::Wasm
    } else if cfg!(unix) {
        Platform::Unix
    } else {
        Platform::Unknown
    }
}

// The convention for Rust identifiers is the snake_case,
// and they are automatically converted to camelCase on the Dart side.
pub fn rust_release_mode() -> bool {
    cfg!(not(debug_assertions))
}

pub fn test() -> String {
    println!("Hello from native!");

    return "Hello Native!".to_owned();
}

// pub fn analyze() -> HashMap<String, serde_json::Value>{

// }

pub struct RtDeviceVec{
    pub(crate) id: String,
    pub(crate) device: String,
    pub(crate) farm: String,
    pub(crate) value: Box<DeviceVal>,
    pub(crate) comment: String,
}

pub enum DeviceVal{
    Single(f64),
    Three(MultiVal),
}

pub struct MultiVal{
    pub(crate) n_value: f64,
    pub(crate) p_value: f64,
    pub(crate) k_value: f64,
}

impl Default for DeviceVal{
    fn default() -> Self {
        Self::Single(0.0);
        Self::Three(MultiVal { n_value: 0.0, p_value: 0.0, k_value: 0.0 })
    }
}

pub enum MaReturnTypes{
    Single(Vec<f64>),
    Triple(TripleVec),
}

pub struct TripleVec{
    pub(crate) n_vec: Vec<f64>,
    pub(crate) p_vec: Vec<f64>,
    pub(crate) k_vec: Vec<f64>
}

impl Default for MaReturnTypes{
    fn default() -> Self {
        Self::Single(vec![0.0]);
        Self::Triple(TripleVec { n_vec: vec![0.0], p_vec: vec![0.0], k_vec: vec![0.0] })
    }
}

pub fn calculate_sma(period: usize, data: Vec<RtDeviceVec>) -> Vec<MaReturnTypes> {
    let mut window = Vec::new();
    let mut window3:Vec<f64> = Vec::new();
    let mut res = Vec::new();

    let mut single_vec = Vec::new();
    let mut nvec = Vec::new();
    let mut pvec = Vec::new();
    let mut kvec = Vec::new();

    for d in data {
        match d.value.as_ref() {
            DeviceVal::Single(s) => {
                window.push(*s);
                if window.len() > period {
                    window.remove(0);
                }
    
                if window.len() >= period {
                    let sum: f64 = window.iter().take(period).sum();
                    let sma_value = sum / period as f64;
                    single_vec.push(sma_value);
                }
            },
            DeviceVal::Three(t) => {
                window3.push(t.n_value);
                window3.push(t.p_value);
                window3.push(t.k_value);
                
                if window3.len() > period * 3 {
                    window3.remove(0);
                    window3.remove(1);
                    window3.remove(2);
                }
    
                if window3.len() >= period * 3 {
                    let nsum: f64 = window3[0] + window3[3] + window3[6];
                    let psum: f64 = window3[1] + window3[4] + window3[7];
                    let ksum: f64 = window3[2] + window3[5] + window3[8];

                    let nsma_value = nsum / period as f64;
                    let psma_value = psum / period as f64;
                    let ksma_value = ksum / period as f64;

                    nvec.push(nsma_value);
                    pvec.push(psma_value);
                    kvec.push(ksma_value);
                }
            },
        };
    }

    res.push(MaReturnTypes::Single(single_vec));
    res.push(MaReturnTypes::Triple(TripleVec { n_vec: nvec, p_vec: pvec, k_vec: kvec }));

    return res;
}

pub fn calculate_ema(period: usize, data: Vec<RtDeviceVec>) -> Vec<MaReturnTypes>{
    // init vars
    let multiplier = 2.0 / ((period + 1) as f64);
    let mut prev_ema_single = 0.0;
    let mut prev_ema_n = 0.0;
    let mut prev_ema_p = 0.0;
    let mut prev_ema_k = 0.0;
    let mut count_single = 0;
    let mut count_multi = 0;
    // sum
    let mut sum_s = 0.0;
    let mut sum_n = 0.0;
    let mut sum_p = 0.0;
    let mut sum_k = 0.0;
    // To return
    let mut single_vec = Vec::new();
    let mut nvec = Vec::new();
    let mut pvec = Vec::new();
    let mut kvec = Vec::new();
    let mut res:Vec<MaReturnTypes> = Vec::new();

    for d in data{
        match d.value.as_ref(){
            DeviceVal::Single(s) => {
                sum_s += s;
                count_single += 1;

                if count_single < period{
                    prev_ema_single = sum_s / (count_single as f64);
                } else {
                    prev_ema_single = (s - prev_ema_single) * multiplier + prev_ema_single;
                }
                single_vec.push(prev_ema_single);
            },
            DeviceVal::Three(t) => {
                sum_n += t.n_value;
                sum_p += t.p_value;
                sum_k += t.k_value;
                count_multi += 1;

                if count_multi < period{
                    prev_ema_n = sum_n / (count_multi as f64);
                    prev_ema_p = sum_p / (count_multi as f64);
                    prev_ema_k = sum_k / (count_multi as f64);
                } else {
                    prev_ema_n = (t.n_value - prev_ema_n) * multiplier + prev_ema_n;
                    prev_ema_p = (t.p_value - prev_ema_p) * multiplier + prev_ema_p;
                    prev_ema_k = (t.k_value - prev_ema_k) * multiplier + prev_ema_k;
                }
                nvec.push(prev_ema_n);
                pvec.push(prev_ema_p);
                kvec.push(prev_ema_k);
            },
        }
    }
    res.push(MaReturnTypes::Single(single_vec));
    res.push(MaReturnTypes::Triple(TripleVec { n_vec: nvec, p_vec: pvec, k_vec: kvec }));

    return res;
}