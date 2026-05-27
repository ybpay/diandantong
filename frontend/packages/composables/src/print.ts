export function usePrint() {
  async function printReceipt(orderId: number, printerIds?: number[]) {
    const { printerApi } = await import('@webpos/api')
    // Print logic handled via server-side print service
    console.log('Printing receipt for order:', orderId, 'printers:', printerIds)
  }

  return { printReceipt }
}
