// Aggregate mock data tuned to match the HRiSENSE UI mockups.
// Fiscal year is Thai Buddhist Era (พ.ศ.). Data snapshot: 20 พ.ค. 2567.

export const SNAPSHOT_LABEL = "20 พฤษภาคม 2567";
export const SNAPSHOT_SHORT = "20 พ.ค. 2567";

export type RiskLevel = "low" | "medium" | "high" | "critical";

export const summaryKpis = {
  totalPersonnel: 3256,
  occupancyRate: 89.5,
  vacancies: 186,
  retiring3yr: 156,
  totalUnits: 32,
};

export const landingKpis = [
  {
    key: "total",
    label: "จำนวนบุคลากรทั้งหมด",
    value: "3,256",
    unit: "คน",
    note: "ข้อมูล ณ วันที่ 20 พ.ค. 2567",
    tone: "info" as const,
    icon: "users",
  },
  {
    key: "occupancy",
    label: "อัตรากำลังปัจจุบัน",
    value: "89.50%",
    unit: "",
    note: "เทียบต่ออัตรากำลังที่มีอยู่",
    tone: "success" as const,
    icon: "userCheck",
  },
  {
    key: "vacancy",
    label: "ตำแหน่งว่าง",
    value: "186",
    unit: "ตำแหน่ง",
    note: "",
    tone: "warning" as const,
    icon: "userPlus",
  },
  {
    key: "retire",
    label: "เกษียณภายใน 3 ปี",
    value: "156",
    unit: "คน",
    note: "",
    tone: "danger" as const,
    icon: "userMinus",
  },
  {
    key: "units",
    label: "หน่วยงานทั้งหมด",
    value: "32",
    unit: "หน่วยงาน",
    note: "",
    tone: "violet" as const,
    icon: "building",
  },
];

export const landingFeatures = [
  {
    title: "พยากรณ์ความเสี่ยงล่วงหน้า",
    icon: "scanSearch",
    tone: "info" as const,
    body: "วิเคราะห์และพยากรณ์ความเสี่ยงด้านกำลังคน เช่น การเกษียณ การโอนย้าย การขาดแคลนบุคลากรสำคัญ",
  },
  {
    title: "วางแผนกำลังคนเชิงรุก",
    icon: "target",
    tone: "success" as const,
    body: "สนับสนุนการวางแผนอัตรากำลัง การสืบทอดตำแหน่ง และการพัฒนาบุคลากรให้สอดคล้องกับการกิจองค์กร",
  },
  {
    title: "ติดตามและวิเคราะห์แบบ Real-time",
    icon: "activity",
    tone: "warning" as const,
    body: "Dashboard แสดงข้อมูลสำคัญแบบเรียลไทม์ ช่วยให้ผู้บริหารตัดสินใจได้รวดเร็วและแม่นยำ",
  },
  {
    title: "ลดความเสี่ยง เพิ่มความต่อเนื่อง",
    icon: "shieldCheck",
    tone: "violet" as const,
    body: "ลดผลกระทบจากการขาดแคลนบุคลากร รักษาองค์ความรู้สำคัญ และเพิ่มความต่อเนื่องในการปฏิบัติราชการ",
  },
];

// Dashboard charts
export const retirementTrend = [
  { year: "2567", count: 29 },
  { year: "2568", count: 48 },
  { year: "2569", count: 37 },
  { year: "2570", count: 24 },
  { year: "2571", count: 18 },
];

export const ageGroups = [
  { name: "น้อยกว่า 30 ปี", value: 12.4, count: 405, color: "#2563eb" },
  { name: "30 - 39 ปี", value: 26.7, count: 870, color: "#22b8cf" },
  { name: "40 - 49 ปี", value: 38.6, count: 1258, color: "#37b24d" },
  { name: "50 - 59 ปี", value: 19.1, count: 623, color: "#f59f00" },
  { name: "60 ปีขึ้นไป", value: 3.2, count: 100, color: "#e8590c" },
];

export const workforceByLine = [
  { name: "บริหาร", count: 214, pct: 6.6 },
  { name: "อำนวยการ/วิชาการ", count: 1256, pct: 38.6 },
  { name: "วิชาการ", count: 1102, pct: 33.8 },
  { name: "ทั่วไป", count: 684, pct: 21.0 },
];

export const movementTrend = [
  { year: "2563", transfer: 70, resign: 45 },
  { year: "2564", transfer: 95, resign: 40 },
  { year: "2565", transfer: 97, resign: 50 },
  { year: "2566", transfer: 90, resign: 60 },
  { year: "2567", transfer: 120, resign: 55 },
];

// Risk analysis
export const overallRisk = {
  level: 3,
  label: "ปานกลาง",
  scale: { low: 1, medium: 3, high: 5 },
};

export const riskFactors = [
  { label: "เกษียณอายุราชการภายใน 3 ปี", level: "high" as RiskLevel, text: "ความเสี่ยงสูง" },
  { label: "ตำแหน่งสำคัญขาดผู้สืบทอด", level: "high" as RiskLevel, text: "ความเสี่ยงสูง" },
  { label: "อัตราว่างในตำแหน่งสายวิชาการ", level: "medium" as RiskLevel, text: "ความเสี่ยงปานกลาง" },
  { label: "อัตราการลาออกของคนเก่ง (Talent Risk)", level: "medium" as RiskLevel, text: "ความเสี่ยงปานกลาง" },
  { label: "อายุเฉลี่ยของบุคลากรในตำแหน่งสำคัญสูง", level: "low" as RiskLevel, text: "ความเสี่ยงต่ำ" },
];

export const riskDistribution = [
  { name: "ความเสี่ยงสูง", value: 5, pct: 35, level: "high" as RiskLevel, color: "#e03131" },
  { name: "ความเสี่ยงปานกลาง", value: 6, pct: 40, level: "medium" as RiskLevel, color: "#f59f00" },
  { name: "ความเสี่ยงต่ำ", value: 4, pct: 25, level: "low" as RiskLevel, color: "#37b24d" },
];

export const topRiskPositions = [
  {
    rank: 1,
    position: "นักวิเคราะห์นโยบายและแผนชำนาญการพิเศษ",
    unit: "กองนโยบายและแผน",
    driver: "เกษียณภายใน 2 ปี / ไม่มีผู้สืบทอด",
    level: "critical" as RiskLevel,
    levelText: "สูงมาก",
    score: 85,
  },
  {
    rank: 2,
    position: "นิติกรชำนาญการพิเศษ",
    unit: "กองกฎหมาย",
    driver: "เกษียณภายใน 3 ปี",
    level: "high" as RiskLevel,
    levelText: "สูง",
    score: 75,
  },
  {
    rank: 3,
    position: "นักวิชาการคอมพิวเตอร์ชำนาญการพิเศษ",
    unit: "ศูนย์เทคโนโลยีสารสนเทศ",
    driver: "คนเก่งลาออก / ออกจากราชการเพิ่มขึ้นสูง",
    level: "high" as RiskLevel,
    levelText: "สูง",
    score: 72,
  },
  {
    rank: 4,
    position: "นักจัดการเงินและบัญชีชำนาญการพิเศษ",
    unit: "กองคลัง",
    driver: "อายุเฉลี่ยสูงมาก",
    level: "medium" as RiskLevel,
    levelText: "ปานกลาง",
    score: 58,
  },
  {
    rank: 5,
    position: "นักทรัพยากรบุคคลชำนาญการพิเศษ",
    unit: "กองบริหารทรัพยากรบุคคล",
    driver: "อัตราว่างในตำแหน่งสูง",
    level: "medium" as RiskLevel,
    levelText: "ปานกลาง",
    score: 55,
  },
];

// Executive summary
export const executiveHighlights = [
  { icon: "users", text: "คาดว่าเกษียณอายุราชการใน 3 ปี", value: "156", unit: "คน" },
  { icon: "userX", text: "ตำแหน่งสำคัญที่ยังไม่มีผู้สืบทอด", value: "28", unit: "ตำแหน่ง" },
  { icon: "barChart", text: "หน่วยงานที่มีอัตรากำลังต่ำกว่าเกณฑ์", value: "9", unit: "หน่วยงาน" },
  { icon: "alert", text: "ความเสี่ยงการขาดแคลนคนสำคัญ (Talent Risk)", value: "สูง", unit: "ใน 3 หน่วยงาน" },
];

export const workforce5yr = [
  { year: "2567", deficit: 1050, near: 1100, surplus: 1106 },
  { year: "2568", deficit: 1080, near: 1090, surplus: 1086 },
  { year: "2569", deficit: 1100, near: 1080, surplus: 1076 },
  { year: "2570", deficit: 1120, near: 1070, surplus: 1066 },
  { year: "2571", deficit: 1150, near: 1060, surplus: 1046 },
];

export const executiveKpis = [
  { label: "จำนวนบุคลากรทั้งหมด", value: "3,256", delta: "เพิ่มขึ้น 2.3% จากปีที่แล้ว", dir: "up" as const, tone: "info" as const, icon: "users" },
  { label: "อัตรากำลังปัจจุบัน", value: "89.50%", delta: "เพิ่มขึ้น 1.8% จากปีที่แล้ว", dir: "up" as const, tone: "success" as const, icon: "userCheck" },
  { label: "ตำแหน่งว่าง", value: "186", delta: "ลดลง 5.6% จากปีที่แล้ว", dir: "down" as const, tone: "warning" as const, icon: "userPlus" },
  { label: "เกษียณภายใน 3 ปี", value: "156", delta: "เพิ่มขึ้น 12.4% จากปีที่แล้ว", dir: "up" as const, tone: "danger" as const, icon: "userMinus" },
  { label: "หน่วยงานที่มีความเสี่ยงสูง", value: "32", delta: "เพิ่มขึ้น 3 หน่วยงาน", dir: "up" as const, tone: "violet" as const, icon: "building" },
];

export const strategicRecommendations = [
  {
    no: 1,
    title: "บริหารกำลังคนเชิงรุก",
    icon: "target",
    tone: "success" as const,
    items: [
      "จัดทำแผนอัตรากำลังระยะสั้น – ระยะยาว ให้สอดคล้องกับภารกิจ",
      "เร่งสรรหาบุคลากรในสายงานที่ขาดแคลน",
      "ทบทวนการกำหนดอัตรากำลังให้เหมาะสมตามภารกิจ",
    ],
  },
  {
    no: 2,
    title: "พัฒนาศักยภาพบุคลากร",
    icon: "users",
    tone: "info" as const,
    items: [
      "จัดทำแผนพัฒนารายบุคคล (IDP) สำหรับตำแหน่งสำคัญ",
      "ส่งเสริมการเรียนรู้และ Upskill/Reskill",
      "พัฒนา Leadership Pipeline สำหรับตำแหน่งบริหาร",
    ],
  },
  {
    no: 3,
    title: "แผนสืบทอดตำแหน่ง",
    icon: "fileText",
    tone: "warning" as const,
    items: [
      "จัดทำ Succession Plan สำหรับตำแหน่งสำคัญ",
      "ระบุและพัฒนาผู้สืบทอดตำแหน่ง (Talent Pool)",
      "ติดตามความพร้อมของผู้สืบทอดอย่างต่อเนื่อง",
    ],
  },
  {
    no: 4,
    title: "รักษาและจูงใจบุคลากร",
    icon: "heart",
    tone: "violet" as const,
    items: [
      "จัดทำแนวทางรักษาบุคลากรสำคัญ",
      "ปรับปรุงสิทธิประโยชน์และสภาพแวดล้อมในการทำงาน",
      "สร้างเส้นทางความก้าวหน้าในสายอาชีพที่ชัดเจน",
    ],
  },
];

// Alerts
export type AlertCategory = "high" | "retire" | "vacancy" | "general";

export const alerts = [
  {
    id: "a1",
    category: "high" as AlertCategory,
    tag: "ความเสี่ยงสูง",
    title: "ตำแหน่ง ผู้อำนวยการกองกฎหมาย",
    lines: ["ไม่มีผู้สืบทอดตำแหน่งที่พร้อม (Talent Risk)", "ควรจัดทำ Succession Plan ด่วน"],
    date: "20 พ.ค. 2567",
    icon: "alert",
  },
  {
    id: "a2",
    category: "retire" as AlertCategory,
    tag: "การเกษียณ",
    title: "คาดว่าจะมีผู้เกษียณภายใน 12 เดือน",
    lines: ["จำนวน 29 คน"],
    date: "19 พ.ค. 2567",
    icon: "userMinus",
  },
  {
    id: "a3",
    category: "vacancy" as AlertCategory,
    tag: "ตำแหน่งว่าง",
    title: "อัตรากำลังไม่เพียงพอ กองคลัง",
    lines: ["ต่ำกว่าเกณฑ์ที่กำหนด 15%"],
    date: "18 พ.ค. 2567",
    icon: "user",
  },
  {
    id: "a4",
    category: "general" as AlertCategory,
    tag: "ทั่วไป",
    title: "อัปเดตข้อมูลบุคลากรไม่สมบูรณ์",
    lines: ["กรุณาตรวจสอบข้อมูล 3 รายการ"],
    date: "17 พ.ค. 2567",
    icon: "userCog",
  },
  {
    id: "a5",
    category: "general" as AlertCategory,
    tag: "ทั่วไป",
    title: "ระบบจะปิดปรับปรุงประจำเดือน",
    lines: ["วันที่ 25 พฤษภาคม 2567 เวลา 22:00 - 02:00 น.", "ขออภัยในความไม่สะดวก"],
    date: "15 พ.ค. 2567",
    icon: "info",
  },
];

export const alertFilters = [
  { key: "all", label: "ทั้งหมด", count: 5 },
  { key: "high", label: "ความเสี่ยงสูง", count: 2 },
  { key: "retire", label: "การเกษียณ", count: 1 },
  { key: "vacancy", label: "ตำแหน่งว่าง", count: 1 },
  { key: "general", label: "ทั่วไป", count: 1 },
];

// Individual profile
export const profile = {
  name: "นางสาวปณิธิรา รัตนมณี",
  position: "นักวิเคราะห์นโยบายและแผนชำนาญการพิเศษ",
  unit: "กองนโยบายและแผน",
  employeeId: "123456",
  startDate: "1 ต.ค. 2545",
  serviceTime: "21 ปี 10 เดือน",
  age: "45 ปี",
  riskScore: 72,
  riskLabel: "เสี่ยงสูง",
  current: {
    position: "นักวิเคราะห์นโยบายและแผนชำนาญการพิเศษ",
    level: "ชำนาญการพิเศษ",
    affiliation: "กองนโยบายและแผน",
    group: "กลุ่มแผนงานและงบประมาณ",
    appointedDate: "1 ก.ค. 2564",
    tenure: "2 ปี 7 เดือน",
  },
  keyInfo: {
    retireAge: "58 ปี 11 เดือน (ปี 2570)",
    retire3yr: "สูง",
    criticalRole: "ใช่",
    successors: "1 คน",
    readiness: "ปานกลาง",
    idp: "มีแผนพัฒนา",
  },
  supervisor: {
    name: "ผู้อำนวยการกองนโยบายและแผน",
    position: "ผู้อำนวยการกองนโยบายและแผน",
    phone: "02-123-4567",
    email: "director.plan@org.go.th",
  },
  tabs: ["ข้อมูลทั่วไป", "ประวัติการศึกษา", "การพัฒนาตนเอง", "ผลการประเมิน", "แผนสืบทอดตำแหน่ง", "ประวัติการลา"],
};

export const currentUser = {
  name: "ณัชชา อนันตวิเชียร",
  role: "นักทรัพยากรบุคคลชำนาญการ",
};
