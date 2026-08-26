/**
 * Minimal dependency-free test runner for the memory store. The Postgres
 * store isn't covered here since it needs a live database — see README
 * for how to smoke-test it manually against a local Postgres instance.
 */
const assert = require('assert');
const { createConversationManager } = require('../src/index');

async function run() {
  const manager = createConversationManager({ mode: 'memory', ttlMs: 50 });
  const tin = '123456789';

  // starts empty
  assert.strictEqual(await manager.getConversation(tin), null, 'expected no conversation yet');

  // appendMessage creates the conversation
  const afterFirst = await manager.appendMessage(tin, { role: 'user', content: 'hi' });
  assert.strictEqual(afterFirst.messages.length, 1);
  assert.strictEqual(afterFirst.tin, tin);

  // appendMessage appends, doesn't overwrite
  const afterSecond = await manager.appendMessage(tin, { role: 'assistant', content: 'hello' });
  assert.strictEqual(afterSecond.messages.length, 2);
  assert.strictEqual(afterSecond.messages[1].content, 'hello');

  // saveConversation replaces the full record
  const saved = await manager.saveConversation(tin, {
    messages: [{ role: 'system', content: 'reset' }],
    metadata: { channel: 'chat' },
  });
  assert.strictEqual(saved.messages.length, 1);
  assert.strictEqual(saved.metadata.channel, 'chat');

  // deleteConversation removes it
  const deleted = await manager.deleteConversation(tin);
  assert.strictEqual(deleted, true);
  assert.strictEqual(await manager.getConversation(tin), null);

  // deleting again returns false
  assert.strictEqual(await manager.deleteConversation(tin), false);

  // invalid TIN is rejected
  await assert.rejects(() => manager.getConversation('not-a-tin'));

  // TTL eviction: wait past ttlMs and confirm the entry is gone
  await manager.appendMessage(tin, { role: 'user', content: 'will expire' });
  await new Promise((resolve) => setTimeout(resolve, 120));
  assert.strictEqual(await manager.getConversation(tin), null, 'expected TTL eviction');

  await manager.close();
  console.log('All memory store tests passed.');
}

run().catch((err) => {
  console.error('Test failed:', err);
  process.exitCode = 1;
});
