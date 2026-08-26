/**
 * Run with:
 *   STORAGE_MODE=memory   node examples/usage.js
 *   STORAGE_MODE=postgres node examples/usage.js   (after `npm run migrate`)
 *
 * Notice the calling code below is identical either way — it only ever
 * talks to the ConversationStore interface returned by
 * createConversationManager().
 */
const { createConversationManager } = require('../src/index');
const { maskTin } = require('../src/util/tin');

async function main() {
  const manager = createConversationManager();

  const tin = '123-45-6789';

  await manager.appendMessage(tin, { role: 'user', content: 'What is my refund status?' });
  await manager.appendMessage(tin, {
    role: 'assistant',
    content: 'Let me look that up for you.',
  });

  const conversation = await manager.getConversation(tin);
  console.log(`Conversation for ${maskTin(tin)}:`);
  console.log(JSON.stringify(conversation, null, 2));

  const keys = await manager.listConversationKeys({ limit: 10 });
  console.log(`Stored conversation count: ${keys.length}`);

  await manager.close();
}

main().catch((err) => {
  console.error('Example failed:', err);
  process.exitCode = 1;
});
