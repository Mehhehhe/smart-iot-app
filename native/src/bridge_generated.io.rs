use super::*;
// Section: wire functions

#[no_mangle]
pub extern "C" fn wire_platform(port_: i64) {
    wire_platform_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_rust_release_mode(port_: i64) {
    wire_rust_release_mode_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_test(port_: i64) {
    wire_test_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_calculate_sma(
    port_: i64,
    period: usize,
    data: *mut wire_list_rt_device_vec,
) {
    wire_calculate_sma_impl(port_, period, data)
}

#[no_mangle]
pub extern "C" fn wire_calculate_ema(
    port_: i64,
    period: usize,
    data: *mut wire_list_rt_device_vec,
) {
    wire_calculate_ema_impl(port_, period, data)
}

// Section: allocate functions

#[no_mangle]
pub extern "C" fn new_box_autoadd_multi_val_0() -> *mut wire_MultiVal {
    support::new_leak_box_ptr(wire_MultiVal::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_box_device_val_0() -> *mut wire_DeviceVal {
    support::new_leak_box_ptr(wire_DeviceVal::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_list_rt_device_vec_0(len: i32) -> *mut wire_list_rt_device_vec {
    let wrap = wire_list_rt_device_vec {
        ptr: support::new_leak_vec_ptr(<wire_RtDeviceVec>::new_with_null_ptr(), len),
        len,
    };
    support::new_leak_box_ptr(wrap)
}

#[no_mangle]
pub extern "C" fn new_uint_8_list_0(len: i32) -> *mut wire_uint_8_list {
    let ans = wire_uint_8_list {
        ptr: support::new_leak_vec_ptr(Default::default(), len),
        len,
    };
    support::new_leak_box_ptr(ans)
}

// Section: related functions

// Section: impl Wire2Api

impl Wire2Api<String> for *mut wire_uint_8_list {
    fn wire2api(self) -> String {
        let vec: Vec<u8> = self.wire2api();
        String::from_utf8_lossy(&vec).into_owned()
    }
}
impl Wire2Api<MultiVal> for *mut wire_MultiVal {
    fn wire2api(self) -> MultiVal {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<MultiVal>::wire2api(*wrap).into()
    }
}
impl Wire2Api<Box<DeviceVal>> for *mut wire_DeviceVal {
    fn wire2api(self) -> Box<DeviceVal> {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<DeviceVal>::wire2api(*wrap).into()
    }
}
impl Wire2Api<DeviceVal> for wire_DeviceVal {
    fn wire2api(self) -> DeviceVal {
        match self.tag {
            0 => unsafe {
                let ans = support::box_from_leak_ptr(self.kind);
                let ans = support::box_from_leak_ptr(ans.Single);
                DeviceVal::Single(ans.field0.wire2api())
            },
            1 => unsafe {
                let ans = support::box_from_leak_ptr(self.kind);
                let ans = support::box_from_leak_ptr(ans.Three);
                DeviceVal::Three(ans.field0.wire2api())
            },
            _ => unreachable!(),
        }
    }
}

impl Wire2Api<Vec<RtDeviceVec>> for *mut wire_list_rt_device_vec {
    fn wire2api(self) -> Vec<RtDeviceVec> {
        let vec = unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        };
        vec.into_iter().map(Wire2Api::wire2api).collect()
    }
}
impl Wire2Api<MultiVal> for wire_MultiVal {
    fn wire2api(self) -> MultiVal {
        MultiVal {
            n_value: self.n_value.wire2api(),
            p_value: self.p_value.wire2api(),
            k_value: self.k_value.wire2api(),
        }
    }
}
impl Wire2Api<RtDeviceVec> for wire_RtDeviceVec {
    fn wire2api(self) -> RtDeviceVec {
        RtDeviceVec {
            id: self.id.wire2api(),
            device: self.device.wire2api(),
            farm: self.farm.wire2api(),
            value: self.value.wire2api(),
            comment: self.comment.wire2api(),
        }
    }
}

impl Wire2Api<Vec<u8>> for *mut wire_uint_8_list {
    fn wire2api(self) -> Vec<u8> {
        unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        }
    }
}

// Section: wire structs

#[repr(C)]
#[derive(Clone)]
pub struct wire_list_rt_device_vec {
    ptr: *mut wire_RtDeviceVec,
    len: i32,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_MultiVal {
    n_value: f64,
    p_value: f64,
    k_value: f64,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_RtDeviceVec {
    id: *mut wire_uint_8_list,
    device: *mut wire_uint_8_list,
    farm: *mut wire_uint_8_list,
    value: *mut wire_DeviceVal,
    comment: *mut wire_uint_8_list,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_uint_8_list {
    ptr: *mut u8,
    len: i32,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_DeviceVal {
    tag: i32,
    kind: *mut DeviceValKind,
}

#[repr(C)]
pub union DeviceValKind {
    Single: *mut wire_DeviceVal_Single,
    Three: *mut wire_DeviceVal_Three,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_DeviceVal_Single {
    field0: f64,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_DeviceVal_Three {
    field0: *mut wire_MultiVal,
}

// Section: impl NewWithNullPtr

pub trait NewWithNullPtr {
    fn new_with_null_ptr() -> Self;
}

impl<T> NewWithNullPtr for *mut T {
    fn new_with_null_ptr() -> Self {
        std::ptr::null_mut()
    }
}

impl NewWithNullPtr for wire_DeviceVal {
    fn new_with_null_ptr() -> Self {
        Self {
            tag: -1,
            kind: core::ptr::null_mut(),
        }
    }
}

#[no_mangle]
pub extern "C" fn inflate_DeviceVal_Single() -> *mut DeviceValKind {
    support::new_leak_box_ptr(DeviceValKind {
        Single: support::new_leak_box_ptr(wire_DeviceVal_Single {
            field0: Default::default(),
        }),
    })
}

#[no_mangle]
pub extern "C" fn inflate_DeviceVal_Three() -> *mut DeviceValKind {
    support::new_leak_box_ptr(DeviceValKind {
        Three: support::new_leak_box_ptr(wire_DeviceVal_Three {
            field0: core::ptr::null_mut(),
        }),
    })
}

impl NewWithNullPtr for wire_MultiVal {
    fn new_with_null_ptr() -> Self {
        Self {
            n_value: Default::default(),
            p_value: Default::default(),
            k_value: Default::default(),
        }
    }
}

impl Default for wire_MultiVal {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}

impl NewWithNullPtr for wire_RtDeviceVec {
    fn new_with_null_ptr() -> Self {
        Self {
            id: core::ptr::null_mut(),
            device: core::ptr::null_mut(),
            farm: core::ptr::null_mut(),
            value: core::ptr::null_mut(),
            comment: core::ptr::null_mut(),
        }
    }
}

impl Default for wire_RtDeviceVec {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}

// Section: sync execution mode utility

#[no_mangle]
pub extern "C" fn free_WireSyncReturn(ptr: support::WireSyncReturn) {
    unsafe {
        let _ = support::box_from_leak_ptr(ptr);
    };
}
