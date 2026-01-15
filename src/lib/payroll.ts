/**
 * Payroll Calculation Utilities
 * Handles BPJS, PPh 21, and component calculations
 */

// PTKP (Penghasilan Tidak Kena Pajak) Values for 2024
export const PTKP_VALUES: Record<string, number> = {
    'TK/0': 54_000_000,  // Single, no dependents
    'TK/1': 58_500_000,  // Single, 1 dependent
    'TK/2': 63_000_000,  // Single, 2 dependents
    'TK/3': 67_500_000,  // Single, 3 dependents
    'K/0': 58_500_000,   // Married, no dependents
    'K/1': 63_000_000,   // Married, 1 dependent
    'K/2': 67_500_000,   // Married, 2 dependents
    'K/3': 72_000_000,   // Married, 3 dependents
};

// Tax Brackets for PPh 21 (2024)
export const TAX_BRACKETS = [
    { limit: 60_000_000, rate: 5 },
    { limit: 250_000_000, rate: 15 },
    { limit: 500_000_000, rate: 25 },
    { limit: 5_000_000_000, rate: 30 },
    { limit: Infinity, rate: 35 },
];

export interface BPJSRates {
    kesehatan_employee: number;
    kesehatan_employer: number;
    tk_jht_employee: number;
    tk_jht_employer: number;
    tk_jp_employee: number;
    tk_jp_employer: number;
}

export interface BPJSCalculation {
    employee: {
        kesehatan: number;
        jht: number;
        jp: number;
        total: number;
    };
    employer: {
        kesehatan: number;
        jht: number;
        jp: number;
        total: number;
    };
}

export interface PayrollComponent {
    id: string;
    name: string;
    type: 'allowance' | 'deduction';
    amount_type: 'fixed' | 'percentage';
    amount: number;
    is_taxable: boolean;
}

export interface EnhancedPayrollCalculation {
    baseSalary: number;
    allowances: Array<{ name: string; amount: number; taxable: boolean }>;
    totalAllowances: number;
    grossSalary: number;
    bpjsEmployee: BPJSCalculation['employee'];
    bpjsEmployer: BPJSCalculation['employer'];
    taxableIncome: number;
    pph21Monthly: number;
    deductions: Array<{ name: string; amount: number }>;
    totalDeductions: number;
    netSalary: number;
}

/**
 * Calculate BPJS contributions
 */
export function calculateBPJS(
    grossSalary: number,
    rates: BPJSRates
): BPJSCalculation {
    const employee = {
        kesehatan: grossSalary * (rates.kesehatan_employee / 100),
        jht: grossSalary * (rates.tk_jht_employee / 100),
        jp: grossSalary * (rates.tk_jp_employee / 100),
        total: 0,
    };
    employee.total = employee.kesehatan + employee.jht + employee.jp;

    const employer = {
        kesehatan: grossSalary * (rates.kesehatan_employer / 100),
        jht: grossSalary * (rates.tk_jht_employer / 100),
        jp: grossSalary * (rates.tk_jp_employer / 100),
        total: 0,
    };
    employer.total = employer.kesehatan + employer.jht + employer.jp;

    return { employee, employer };
}

/**
 * Calculate PPh 21 annual tax
 */
export function calculatePPh21Annual(
    annualGrossIncome: number,
    ptkpStatus: string
): number {
    const ptkp = PTKP_VALUES[ptkpStatus] || PTKP_VALUES['TK/0'];
    const taxableIncome = Math.max(0, annualGrossIncome - ptkp);

    let tax = 0;
    let remaining = taxableIncome;
    let previousLimit = 0;

    for (const bracket of TAX_BRACKETS) {
        const bracketAmount = Math.min(remaining, bracket.limit - previousLimit);
        tax += bracketAmount * (bracket.rate / 100);
        remaining -= bracketAmount;
        previousLimit = bracket.limit;
        if (remaining <= 0) break;
    }

    return tax;
}

/**
 * Calculate monthly PPh 21
 */
export function calculatePPh21Monthly(
    monthlyGrossIncome: number,
    ptkpStatus: string
): number {
    const annualIncome = monthlyGrossIncome * 12;
    const annualTax = calculatePPh21Annual(annualIncome, ptkpStatus);
    return annualTax / 12;
}

/**
 * Calculate component amount based on type
 */
export function calculateComponentAmount(
    component: PayrollComponent,
    baseSalary: number,
    customAmount?: number
): number {
    if (customAmount !== undefined && customAmount !== null) {
        return customAmount;
    }

    if (component.amount_type === 'fixed') {
        return component.amount;
    } else {
        // Percentage of base salary
        return baseSalary * (component.amount / 100);
    }
}

/**
 * Main payroll calculation function
 */
export function calculateEnhancedPayroll(
    baseSalary: number,
    components: Array<PayrollComponent & { custom_amount?: number }>,
    bpjsRates: BPJSRates,
    ptkpStatus: string,
    usePph21: boolean
): EnhancedPayrollCalculation {
    // Calculate allowances
    const allowanceComponents = components.filter((c) => c.type === 'allowance');
    const allowances = allowanceComponents.map((c) => ({
        name: c.name,
        amount: calculateComponentAmount(c, baseSalary, c.custom_amount),
        taxable: c.is_taxable,
    }));
    const totalAllowances = allowances.reduce((sum, a) => sum + a.amount, 0);

    // Gross salary = base + allowances
    const grossSalary = baseSalary + totalAllowances;

    // Calculate BPJS
    const bpjs = calculateBPJS(grossSalary, bpjsRates);

    // Calculate taxable income
    const taxableAllowances = allowances
        .filter((a) => a.taxable)
        .reduce((sum, a) => sum + a.amount, 0);
    const taxableIncome = baseSalary + taxableAllowances;

    // Calculate PPh 21
    const pph21Monthly = usePph21
        ? calculatePPh21Monthly(taxableIncome, ptkpStatus)
        : 0;

    // Calculate deductions
    const deductionComponents = components.filter((c) => c.type === 'deduction');
    const deductions = [
        ...deductionComponents.map((c) => ({
            name: c.name,
            amount: calculateComponentAmount(c, baseSalary, c.custom_amount),
        })),
        {
            name: 'BPJS Kesehatan',
            amount: bpjs.employee.kesehatan,
        },
        {
            name: 'BPJS TK JHT',
            amount: bpjs.employee.jht,
        },
        {
            name: 'BPJS TK JP',
            amount: bpjs.employee.jp,
        },
    ];

    if (usePph21) {
        deductions.push({
            name: 'PPh 21',
            amount: pph21Monthly,
        });
    }

    const totalDeductions = deductions.reduce((sum, d) => sum + d.amount, 0);

    // Net salary
    const netSalary = grossSalary - totalDeductions;

    return {
        baseSalary,
        allowances,
        totalAllowances,
        grossSalary,
        bpjsEmployee: bpjs.employee,
        bpjsEmployer: bpjs.employer,
        taxableIncome,
        pph21Monthly,
        deductions,
        totalDeductions,
        netSalary,
    };
}

/**
 * Format currency to Indonesian Rupiah
 */
export function formatCurrency(amount: number): string {
    return new Intl.NumberFormat('id-ID', {
        style: 'currency',
        currency: 'IDR',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0,
    }).format(amount);
}
